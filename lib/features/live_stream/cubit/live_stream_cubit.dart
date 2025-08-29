import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/enums.dart';
import '../../../core/services/agora_service.dart';
import '../model/reactions_model.dart';
import '../model/stream_state_model.dart';
import '../repo/firebase_repo_data.dart';
import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  final LiveStreamRepository _firebaseRepository;
  final AgoraService _agoraService;

  AgoraService get agoraService => _agoraService;

  late String _channelName;
  late String _userName;
  late bool _isHost;

  StreamStateModel _streamState = const StreamStateModel();
  Timer? _reactionCleanupTimer;

  // Stream subscriptions
  StreamSubscription? _viewerCountSubscription;
  StreamSubscription? _guestsSubscription;
  StreamSubscription? _reactionsSubscription;

  LiveStreamCubit(this._firebaseRepository, this._agoraService)
    : super(LiveStreamState());

  Future<void> initializeStream({
    required String channelName,
    required String userName,
    required bool isHost,
  }) async {
    try {
      emit(state.copyWith(liveStramStatus: RequestState.loading));

      _channelName = channelName;
      _userName = userName;
      _isHost = isHost;

      // Initialize Firebase
      _firebaseRepository.initializeReferences(channelName);
      _setupFirebaseListeners();

      // Initialize Agora
      await _initializeAgora();

      // Start reaction cleanup timer
      _startReactionCleanup();
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: "Initialization failed: $e",
        ),
      );
    }
  }

  void _setupFirebaseListeners() {
    // Listen to viewer count changes
    _viewerCountSubscription = _firebaseRepository
        .getViewerCountStream()
        .listen((viewerCount) {
          _streamState = _streamState.copyWith(viewerCount: viewerCount);

          emit(
            state.copyWith(
              liveStramStatus: RequestState.done,
              streamState: _streamState,
            ),
          );
          // emit(LiveStreamConnected(_streamState));
        });

    // Listen to guests changes (only for host)
    if (_isHost) {
      _guestsSubscription = _firebaseRepository.getGuestsStream().listen((
        guests,
      ) {
        _streamState = _streamState.copyWith(guests: guests);
        emit(
          state.copyWith(
            liveStramStatus: RequestState.done,
            streamState: _streamState,
          ),
        );
      });
    }

    // Listen to reactions
    _reactionsSubscription = _firebaseRepository.getReactionsStream().listen((
      reaction,
    ) {
      emit(
        state.copyWith(
          reactionStatus: RequestState.done,
          latestReaction: reaction,
        ),
      );

      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );
    });
  }

  Future<void> _initializeAgora() async {
    try {
      _streamState = _streamState.copyWith(status: "Checking permissions...");
      emit(state.copyWith(liveStramStatus: RequestState.done));

      // Check permissions
      final hasPermissions = await agoraService.requestPermissions();
      if (!hasPermissions) {
        emit(
          state.copyWith(
            liveStramStatus: RequestState.error,
            errorMessage: "Permissions not granted",
          ),
        );
        return;
      }

      _streamState = _streamState.copyWith(status: "Creating engine...");
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );

      // Initialize engine
      await agoraService.initializeEngine();

      _streamState = _streamState.copyWith(status: "Setting up channel...");
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );

      // Setup channel
      await agoraService.setupChannel(_isHost);

      // Register event handlers
      agoraService.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: _onJoinChannelSuccess,
          onUserJoined: _onUserJoined,
          onUserOffline: _onUserOffline,
          onError: _onError,
          onLeaveChannel: _onLeaveChannel,
        ),
      );

      // Enable media based on role
      if (_isHost) {
        await agoraService.enableMediaForHost();
      } else {
        await agoraService.enableVideoForGuest();
      }

      _streamState = _streamState.copyWith(
        status: "Joining channel...",
        isInitialized: true,
      );
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );

      // Join channel
      await agoraService.joinChannel(_channelName, _isHost);
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: "Agora initialization failed: $e",
        ),
      );
    }
  }

  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    _streamState = _streamState.copyWith(isJoined: true, status: "Connected");
    emit(
      state.copyWith(
        liveStramStatus: RequestState.done,
        streamState: _streamState,
      ),
    );
    _updateViewerCount(true);
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    if (!_isHost) {
      _streamState = _streamState.copyWith(remoteUid: remoteUid);
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );
    }
  }

  void _onUserOffline(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  ) {
    if (!_isHost && _streamState.remoteUid == remoteUid) {
      _streamState = _streamState.copyWith(remoteUid: 0);
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );
    }
  }

  void _onError(ErrorCodeType errorCode, String message) {
    _streamState = _streamState.copyWith(status: "Error: $message");
    emit(
      state.copyWith(
        liveStramStatus: RequestState.error,
        errorMessage: "Agora Error: $message",
      ),
    );
  }

  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    _streamState = _streamState.copyWith(
      isJoined: false,
      status: "Disconnected",
    );
    emit(
      state.copyWith(
        liveStramStatus: RequestState.done,
        streamState: _streamState,
      ),
    );
    _updateViewerCount(false);
  }

  Future<void> toggleMute() async {
    if (!_isHost) return;

    final newMutedState = !_streamState.isMuted;
    await agoraService.muteLocalAudio(newMutedState);
    _streamState = _streamState.copyWith(isMuted: newMutedState);
    emit(
      state.copyWith(
        liveStramStatus: RequestState.done,
        streamState: _streamState,
      ),
    );
  }

  Future<void> toggleCamera() async {
    if (!_isHost) return;

    final newCameraState = !_streamState.isCameraOff;
    await agoraService.muteLocalVideo(newCameraState);
    _streamState = _streamState.copyWith(isCameraOff: newCameraState);
    emit(
      state.copyWith(
        liveStramStatus: RequestState.done,
        streamState: _streamState,
      ),
    );
  }

  Future<void> switchCamera() async {
    if (!_isHost) return;
    await agoraService.switchCamera();
  }

  Future<void> sendReaction(String emoji) async {
    try {
      final reaction = Reaction(
        emoji: emoji,
        userName: _userName,
        timestamp: DateTime.now(),
        id: '',
      );
      await _firebaseRepository.sendReaction(reaction);
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: 'Error sending reaction: $e',
        ),
      );
    }
  }

  Future<void> _updateViewerCount(bool increment) async {
    await _firebaseRepository.updateViewerCount(increment);
  }

  void _startReactionCleanup() {
    _reactionCleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _firebaseRepository.cleanupOldReactions();
    });
  }

  Future<void> leaveStream() async {
    try {
      if (_streamState.isJoined) {
        await _updateViewerCount(false);

        // Remove guest from Firebase when leaving
        if (!_isHost) {
          await _firebaseRepository.removeGuest(_userName);
        }
      }

      emit(state.copyWith(liveStramStatus: RequestState.done));
      await agoraService.leaveChannel();
      await agoraService.release();
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: 'Error leaving stream: $e',
        ),
      );
    }
  }

  Future<void> pauseStreaming() async {
    if (!_isHost || !_streamState.isJoined) return;

    try {
      // Pause video transmission
      await _agoraService.muteLocalVideo(true);

      // Update state to paused
      _streamState = _streamState.copyWith(
        isPaused: true,
        status: "Stream paused",
      );
      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );

      // Optionally send a message to viewers
      await _notifyViewersOfPause(true);
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: "Failed to pause stream: $e",
        ),
      );
    }
  }

  Future<void> resumeStreaming() async {
    if (!_isHost || !_streamState.isJoined) return;

    try {
      // Resume video transmission if camera was not manually turned off
      if (!_streamState.isCameraOff) {
        await _agoraService.muteLocalVideo(false);
      }

      // Update state to resumed
      _streamState = _streamState.copyWith(
        isPaused: false,
        status: "Connected",
      );

      emit(
        state.copyWith(
          liveStramStatus: RequestState.done,
          streamState: _streamState,
        ),
      );
      // Notify viewers that stream resumed
      await _notifyViewersOfPause(false);
    } catch (e) {
      emit(
        state.copyWith(
          liveStramStatus: RequestState.error,
          errorMessage: "Failed to resume stream: $e",
        ),
      );
    }
  }

  Future<void> _notifyViewersOfPause(bool isPaused) async {
    try {
      // Send a special message to Firebase to notify viewers
      await _firebaseRepository.sendStreamStatus(
        _channelName,
        isPaused ? 'paused' : 'live',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Failed to notify viewers: $e");
      }
    }
  }

  @override
  Future<void> close() async {
    await leaveStream();

    _viewerCountSubscription?.cancel();
    _guestsSubscription?.cancel();
    _reactionsSubscription?.cancel();
    _reactionCleanupTimer?.cancel();
    return super.close();
  }
}
