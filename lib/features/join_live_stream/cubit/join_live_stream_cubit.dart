import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../../core/extensions/enums.dart';
import 'join_live_stream_state.dart';

class PreJoinCubit extends Cubit<PreJoinState> {
  PreJoinCubit() : super(const PreJoinState());

  void initialize() {
    testFirebaseConnection();
  }

  Future<void> testFirebaseConnection() async {
    emit(
      state.copyWith(
        firebaseStatus: FirebaseConnectionStatus.connecting,
        errorMessage: null,
      ),
    );

    try {
      debugPrint('🔄 Testing Firebase connection...');

      final testRef = FirebaseDatabase.instance.ref().child('test');
      await testRef.set({
        'timestamp': ServerValue.timestamp,
        'message': 'Firebase connected!',
      });

      final snapshot = await testRef.get();

      if (snapshot.exists) {
        debugPrint('✅ Firebase connection successful: ${snapshot.value}');
        emit(
          state.copyWith(
            firebaseStatus: FirebaseConnectionStatus.connected,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            firebaseStatus: FirebaseConnectionStatus.error,
            errorMessage: "⚠️ Firebase write successful but read failed",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          firebaseStatus: FirebaseConnectionStatus.error,
          errorMessage:
              "❌ Firebase connection failed. $e",
        ),
      );
    }
  }

  /// Retry Firebase connection
  void retryFirebaseConnection() {
    testFirebaseConnection();
  }

  /// Check if channel exists and determine user role
  Future<void> checkChannelAndJoin(String channelName, String userName) async {
    if (!state.isFirebaseConnected) {
      emit(
        state.copyWith(
          status: RequestState.error,
          errorMessage:
              "Firebase not connected. Please wait or retry connection.",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RequestState.loading,
        channelStatus: ChannelCheckStatus.checking,
        errorMessage: null,
        channelName: channelName.trim(),
        userName: userName.trim(),
      ),
    );

    try {
      final cleanChannelName = channelName.trim();
      final cleanUserName = userName.trim();

      final channelRef = FirebaseDatabase.instance
          .ref()
          .child('streams')
          .child(cleanChannelName);

      final snapshot = await channelRef.get();

      if (!snapshot.exists) {
        // Channel doesn't exist - user becomes host
        await _createChannelAsHost(channelRef, cleanUserName);
      } else {
        // Channel exists - user becomes guest
        await _joinChannelAsGuest(channelRef, cleanUserName, cleanChannelName);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RequestState.error,
          channelStatus: ChannelCheckStatus.error,
          errorMessage: "❌ Failed to join channel: ${e.toString()}",
        ),
      );
    }
  }

  /// Create new channel with current user as host
  Future<void> _createChannelAsHost(
    DatabaseReference channelRef,
    String userName,
  ) async {
    try {
      debugPrint('🎥 Creating new channel - User will be HOST');

      emit(state.copyWith(channelStatus: ChannelCheckStatus.notFound));

      // Create channel structure
      await channelRef.set({
        'host': {
          'name': userName,
          'uid': 0, // Will be updated when Agora assigns actual UID
          'joinedAt': ServerValue.timestamp,
          'isActive': true,
        },
        'viewerCount': 0,
        'guests': {},
        'createdAt': ServerValue.timestamp,
        'isActive': true,
      });

      debugPrint('✅ Channel created successfully - User is HOST');

      emit(
        state.copyWith(
          status: RequestState.done,
          channelStatus: ChannelCheckStatus.notFound,
          isHost: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creating channel: $e');
      emit(
        state.copyWith(
          status: RequestState.error,
          channelStatus: ChannelCheckStatus.error,
          errorMessage: "Failed to create channel: ${e.toString()}",
        ),
      );
    }
  }

  /// Join existing channel as guest
  Future<void> _joinChannelAsGuest(
    DatabaseReference channelRef,
    String userName,
    String channelName,
  ) async {
    try {
      debugPrint('👥 Joining existing channel as GUEST');

      emit(state.copyWith(channelStatus: ChannelCheckStatus.found));

      // Check if host is still active
      final hostSnapshot = await channelRef.child('host').get();
      if (!hostSnapshot.exists) {
        emit(
          state.copyWith(
            status: RequestState.error,
            channelStatus: ChannelCheckStatus.error,
            errorMessage: "Channel exists but no host found. Please try again.",
          ),
        );
        return;
      }

      final hostData = hostSnapshot.value as Map<dynamic, dynamic>;
      final isHostActive = hostData['isActive'] ?? false;

      if (!isHostActive) {
        emit(
          state.copyWith(
            status: RequestState.error,
            channelStatus: ChannelCheckStatus.error,
            errorMessage:
                "Host is not currently active. Please try again later.",
          ),
        );
        return;
      }

      // Check if username is already taken
      final existingGuest = await channelRef
          .child('guests')
          .child(userName)
          .get();

      if (existingGuest.exists) {
        emit(
          state.copyWith(
            status: RequestState.error,
            channelStatus: ChannelCheckStatus.error,
            errorMessage:
                "Username '$userName' is already taken in this channel. Please choose a different name.",
          ),
        );
        return;
      }

      // Add user as guest
      await channelRef.child('guests').child(userName).set({
        'name': userName,
        'joinedAt': ServerValue.timestamp,
        'isActive': true,
      });

      debugPrint('✅ Successfully joined as GUEST');

      emit(
        state.copyWith(
          status: RequestState.done,
          channelStatus: ChannelCheckStatus.found,
          isHost: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error joining as guest: $e');
      emit(
        state.copyWith(
          status: RequestState.error,
          channelStatus: ChannelCheckStatus.error,
          errorMessage: "Failed to join as guest: ${e.toString()}",
        ),
      );
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(status: RequestState.initial, errorMessage: null));
  }

  /// Reset state to initial
  void reset() {
    emit(const PreJoinState());
  }
}
