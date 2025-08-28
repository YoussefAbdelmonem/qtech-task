import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtech_task/features/live_stream/widgets/reaction_animation_cubit.dart';

import '../../core/services/agora_service.dart';
import '../../core/utils/constant.dart';
import 'cubit/live_stream_cubit.dart';
import 'cubit/live_stream_state.dart';
import 'repo/firebase_repo_data.dart';
import 'widgets/reactions_animation_widget.dart';
import 'widgets/video_view_widget.dart';

class LiveStreamScreen extends StatefulWidget {
  final String channelName;
  final String userName;
  final bool isHost;

  const LiveStreamScreen({
    super.key,
    required this.channelName,
    required this.userName,
    required this.isHost,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LiveStreamCubit(FirebaseRepository(), AgoraService())
                ..initializeStream(
                  channelName: widget.channelName,
                  userName: widget.userName,
                  isHost: widget.isHost,
                ),
        ),
        BlocProvider(create: (context) => ReactionAnimationCubit(this)),
      ],
      child: LiveStreamView(
        channelName: widget.channelName,
        userName: widget.userName,
        isHost: widget.isHost,
      ),
    );
  }
}

class LiveStreamView extends StatelessWidget {
  final String channelName;
  final String userName;
  final bool isHost;

  const LiveStreamView({
    super.key,
    required this.channelName,
    required this.userName,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          isHost ? 'Hosting Live Stream' : 'Watching Live Stream',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<LiveStreamCubit>().leaveStream();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout_sharp, color: Colors.red),
          ),
        ],
      ),
      body: BlocConsumer<LiveStreamCubit, LiveStreamState>(
       listener: (context, state) {
          if (state is LiveStreamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReactionReceived) {
            context.read<ReactionAnimationCubit>().addReaction(state.reaction);
          }
        },
        builder: (context, state) {
          if (state is LiveStreamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LiveStreamError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LiveStreamCubit>().initializeStream(
                        channelName: channelName,
                        userName: userName,
                        isHost: isHost,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LiveStreamConnected) {
           return Stack(
              children: [
                // Main video view - safely access engine
                VideoViewWidget(
                  streamState: state.streamState,
                  engine: context.read<LiveStreamCubit>().agoraService.engine,
                  isHost: isHost,
                  channelName: channelName,
                ),

                // Reaction animations overlay
                const ReactionAnimationsWidget(),

                // Top overlay with channel info and viewer count
                if (state.streamState.isJoined) _buildTopOverlay(state),

                // Guest list (only visible to host)
                if (isHost && state.streamState.guests.isNotEmpty)
                  _buildGuestList(state.streamState.guests),

                // Reaction panel
                if (!isHost) _buildReactionPanel(context, state.streamState),

                // Host controls (only for host)
                if (isHost) _buildHostControls(context, state.streamState),

                // Guest status indicator
                if (!isHost) _buildGuestStatus(state.streamState),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTopOverlay(LiveStreamConnected state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "LIVE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isHost)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "HOST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Channel: $channelName",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatViewerCount(state.streamState.viewerCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestList(Map<String, dynamic> guests) {
    return Positioned(
      left: 16,
      top: 120,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Guests Watching:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...guests.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        entry.value['name'] ?? entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionPanel(BuildContext context, state) {
    if (!state.isJoined) return const SizedBox.shrink();

    return Positioned(
      bottom: 120,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "React",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AgoraConstants.availableReactions.map((emoji) {
                return GestureDetector(
                  onTap: () =>
                      context.read<LiveStreamCubit>().sendReaction(emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostControls(BuildContext context, state) {
    if (!state.isJoined) return const SizedBox.shrink();

    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: state.isMuted ? Icons.mic_off : Icons.mic,
              isActive: state.isMuted,
              onTap: () => context.read<LiveStreamCubit>().toggleMute(),
            ),
            _buildControlButton(
              icon: state.isCameraOff ? Icons.videocam_off : Icons.videocam,
              isActive: state.isCameraOff,
              onTap: () => context.read<LiveStreamCubit>().toggleCamera(),
            ),
            _buildControlButton(
              icon: Icons.cameraswitch,
              isActive: false,
              onTap: () => context.read<LiveStreamCubit>().switchCamera(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildGuestStatus(state) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              state.remoteUid != 0
                  ? "Watching live stream"
                  : "Waiting for host...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    } else {
      return count.toString();
    }
  }
}
