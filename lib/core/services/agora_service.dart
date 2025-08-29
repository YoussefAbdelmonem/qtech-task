import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/constant.dart';

class AgoraService {

  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();


  RtcEngine? _engine;
  RtcEngine? get engine => _engine;
  
  bool get isInitialized => _engine != null;

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera] == PermissionStatus.granted &&
           statuses[Permission.microphone] == PermissionStatus.granted;
  }

  Future<void> initializeEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(appId: AgoraConstants.appId));
  }

  Future<void> setupChannel(bool isHost) async {
    if (_engine == null) return;
    
    await _engine!.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );

    await _engine!.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );
  }

  Future<void> enableMediaForHost() async {
    if (_engine == null) return;
    
    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.startPreview();
  }

  Future<void> enableVideoForGuest() async {
    if (_engine == null) return;
    await _engine!.enableVideo();
  }

  Future<void> joinChannel(String channelName, bool isHost) async {
    if (_engine == null) return;
    
    await _engine!.joinChannel(
      token: AgoraConstants.token,
      channelId: channelName,
      uid: AgoraConstants.uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: isHost
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
  }

  Future<void> release() async {
    if (_engine == null) return;
    await _engine!.release();
    _engine = null;
  }

  Future<void> muteLocalAudio(bool mute) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(mute);
  }

  Future<void> muteLocalVideo(bool mute) async {
    if (_engine == null) return;
    await _engine!.muteLocalVideoStream(mute);
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  void registerEventHandler(RtcEngineEventHandler handler) {
    if (_engine == null) return;
    _engine!.registerEventHandler(handler);
  }
}