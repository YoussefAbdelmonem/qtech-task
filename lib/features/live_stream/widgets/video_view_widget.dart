import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../model/stream_state_model.dart';

class VideoViewWidget extends StatelessWidget {
  final StreamStateModel streamState;
  final RtcEngine? engine;
  final bool isHost;
  final String channelName;

  const VideoViewWidget({
    super.key,
    required this.streamState,
    required this.engine,
    required this.isHost,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    if (!streamState.isJoined || !streamState.isInitialized || engine == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              streamState.status,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isHost) {
      // Host view - show their own camera
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Guest view - show host's camera or waiting message
      if (streamState.remoteUid != 0) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine!,
            canvas: VideoCanvas(uid: streamState.remoteUid),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      } else {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                SizedBox(height: 16),
                Text(
                  "Waiting for host to start streaming...",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}