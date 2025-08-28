import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/services/agora_service.dart';

import '../live_stream_screen.dart';
import '../model/reactions_model.dart';
import '../model/stream_state_model.dart';
import '../repo/firebase_repo_data.dart';
import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  final FirebaseRepository _firebaseRepository;
  final AgoraService _agoraService;

  // Expose agoraService for accessing the engine
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
    : super(LiveStreamInitial());

  Future<void> initializeStream({
    required String channelName,
    required String userName,
    required bool isHost,
  }) async {
    try {
      emit(LiveStreamLoading());

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
      emit(LiveStreamError("Initialization failed: $e"));
    }
  }

  void _setupFirebaseListeners() {
    // Listen to viewer count changes
    _viewerCountSubscription = _firebaseRepository
        .getViewerCountStream()
        .listen((viewerCount) {
          _streamState = _streamState.copyWith(viewerCount: viewerCount);
          emit(LiveStreamConnected(_streamState));
        });

    // Listen to guests changes (only for host)
    if (_isHost) {
      _guestsSubscription = _firebaseRepository.getGuestsStream().listen((
        guests,
      ) {
        _streamState = _streamState.copyWith(guests: guests);
        emit(LiveStreamConnected(_streamState));
      });
    }

    // Listen to reactions
    _reactionsSubscription = _firebaseRepository.getReactionsStream().listen((
      reaction,
    ) {
      if (reaction is Reaction) {
        emit(ReactionReceived(reaction));
      }
      emit(LiveStreamConnected(_streamState));
    });
  }

  Future<void> _initializeAgora() async {
    try {
      _streamState = _streamState.copyWith(status: "Checking permissions...");
      emit(LiveStreamConnected(_streamState));

      // Check permissions
      final hasPermissions = await agoraService.requestPermissions();
      if (!hasPermissions) {
        emit(const LiveStreamError("Permissions not granted"));
        return;
      }

      _streamState = _streamState.copyWith(status: "Creating engine...");
      emit(LiveStreamConnected(_streamState));

      // Initialize engine
      await agoraService.initializeEngine();

      _streamState = _streamState.copyWith(status: "Setting up channel...");
      emit(LiveStreamConnected(_streamState));

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
      emit(LiveStreamConnected(_streamState));

      // Join channel
      await agoraService.joinChannel(_channelName, _isHost);
    } catch (e) {
      emit(LiveStreamError("Agora initialization failed: $e"));
    }
  }

  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    _streamState = _streamState.copyWith(isJoined: true, status: "Connected");
    emit(LiveStreamConnected(_streamState));
    _updateViewerCount(true);
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    if (!_isHost) {
      _streamState = _streamState.copyWith(remoteUid: remoteUid);
      emit(LiveStreamConnected(_streamState));
    }
  }

  void _onUserOffline(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  ) {
    if (!_isHost && _streamState.remoteUid == remoteUid) {
      _streamState = _streamState.copyWith(remoteUid: 0);
      emit(LiveStreamConnected(_streamState));
    }
  }

  void _onError(ErrorCodeType errorCode, String message) {
    _streamState = _streamState.copyWith(status: "Error: $message");
    emit(LiveStreamConnected(_streamState));
  }

  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    _streamState = _streamState.copyWith(
      isJoined: false,
      status: "Disconnected",
    );
    emit(LiveStreamConnected(_streamState));
    _updateViewerCount(false);
  }

  Future<void> toggleMute() async {
    if (!_isHost) return;

    final newMutedState = !_streamState.isMuted;
    await agoraService.muteLocalAudio(newMutedState);
    _streamState = _streamState.copyWith(isMuted: newMutedState);
    emit(LiveStreamConnected(_streamState));
  }

  Future<void> toggleCamera() async {
    if (!_isHost) return;

    final newCameraState = !_streamState.isCameraOff;
    await agoraService.muteLocalVideo(newCameraState);
    _streamState = _streamState.copyWith(isCameraOff: newCameraState);
    emit(LiveStreamConnected(_streamState));
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
      emit(LiveStreamError('Error sending reaction: $e'));
    }
  }

  Future<void> _updateViewerCount(bool increment) async {
    try {
      await _firebaseRepository.updateViewerCount(increment);
    } catch (e) {
      // Handle silently or log
    }
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

      await agoraService.leaveChannel();
      await agoraService.release();
    } catch (e) {
      // Handle silently
    }
  }

  @override
  Future<void> close() {
    _viewerCountSubscription?.cancel();
    _guestsSubscription?.cancel();
    _reactionsSubscription?.cancel();
    _reactionCleanupTimer?.cancel();
    leaveStream();
    return super.close();
  }
}
