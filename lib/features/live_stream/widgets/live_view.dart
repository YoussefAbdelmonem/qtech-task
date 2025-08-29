import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtech_task/core/widgets/custom_loading.dart';
import '../../../core/utils/constant.dart';
import '../../../core/widgets/error_widget.dart';
import '../../join_live_stream/prejoin_live_screen.dart';
import '../cubit/live_stream_cubit.dart';
import '../cubit/live_stream_state.dart';
import 'guest_list_widget.dart';
import 'paused_video_widget.dart';
import 'reaction_animation_cubit.dart';
import 'reactions_animation_widget.dart';
import 'video_view_widget.dart';

class LiveStreamView extends StatefulWidget {
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
  State<LiveStreamView> createState() => _LiveStreamViewState();
}

class _LiveStreamViewState extends State<LiveStreamView>
    with WidgetsBindingObserver {
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    // Add observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final cubit = context.read<LiveStreamCubit>();

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed(cubit);
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive(cubit);
        break;
      case AppLifecycleState.paused:
        _handleAppPaused(cubit);
        break;
      case AppLifecycleState.detached:
        _handleAppDetached(cubit);
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden(cubit);
        break;
    }
  }

  void _handleAppResumed(LiveStreamCubit cubit) {
    if (_isInBackground) {
      _isInBackground = false;
      if (widget.isHost) {
        // Resume video streaming for host
        cubit.resumeStreaming();
      }
    }
  }

  void _handleAppInactive(LiveStreamCubit cubit) {
    if (widget.isHost) {
      cubit.pauseStreaming();
    }
  }

  void _handleAppPaused(LiveStreamCubit cubit) {
    _isInBackground = true;
    if (widget.isHost) {
      cubit.pauseStreaming();
    }
  }

  void _handleAppDetached(LiveStreamCubit cubit) {
    // App is about to be terminated
    _handleStreamCleanup(cubit);
  }

  void _handleAppHidden(LiveStreamCubit cubit) {
    //  (iOS specific)
    if (widget.isHost) {
      cubit.pauseStreaming();
    }
  }

  void _handleStreamCleanup(LiveStreamCubit cubit) {
    // Clean exit from stream
    cubit.leaveStream();
  }

  Future<bool> _onWillPop() async {
    final cubit = context.read<LiveStreamCubit>();

    if (widget.isHost) {
      return await _showExitConfirmationDialog() ?? false;
    } else {
      // Guests can leave immediately
      cubit.leaveStream();
      return true;
    }
  }

  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Live Stream?'),
          content: const Text(
            'Are you sure you want to end the live stream? All viewers will be disconnected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            BlocConsumer<LiveStreamCubit, LiveStreamState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    context.read<LiveStreamCubit>().leaveStream();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('End Stream'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.isHost ? 'Hosting Live Stream' : 'Watching Live Stream',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => PreJoinScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => PreJoinScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_sharp, color: Colors.red),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<LiveStreamCubit, LiveStreamState>(
          listener: (context, state) {
            if (state.liveStramStatus.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state.reactionStatus.isDone &&
                state.latestReaction != null) {
              context.read<ReactionAnimationCubit>().addReaction(
                state.latestReaction!,
              );
            }
          },
          builder: (context, state) {
            // Show pause indicator when app is in background
            if (_isInBackground && widget.isHost) {
              return PausedVideoWidget(isInBackground: _isInBackground);
            }

            if (state.liveStramStatus.isLoading) {
              return LoadingApp();
            }

            if (state.liveStramStatus.isError) {
              return CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  context.read<LiveStreamCubit>().initializeStream(
                    channelName: widget.channelName,
                    userName: widget.userName,
                    isHost: widget.isHost,
                  );
                },
              );
            }

            if (state.liveStramStatus.isDone && state.streamState != null) {
              return Stack(
                children: [
                  // Main video view
                  VideoViewWidget(
                    streamState: state.streamState!,
                    engine: context.read<LiveStreamCubit>().agoraService.engine,
                    isHost: widget.isHost,
                    channelName: widget.channelName,
                  ),

                  // Reaction animations overlay
                  const ReactionAnimationsWidget(),

                  // Top overlay with stream info
                  if (state.streamState!.isJoined)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
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
                                            color: state.streamState!.isPaused
                                                ? Colors.orange
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            state.streamState!.isPaused
                                                ? "PAUSED"
                                                : "LIVE",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            widget.userName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (widget.isHost)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                      "Channel: ${widget.channelName}",
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
                                    const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      state.streamState!.viewerCount.toString(),
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
                    ),

                  // Guest list (only visible to host)
                  if (widget.isHost && state.streamState!.guests.isNotEmpty)
                    GuestListWidget(guests: state.streamState!.guests),

                  // Reaction panel
                  if (!widget.isHost)
                    buildReactionPanel(context, state.streamState),

                  // Host controls (only for host)
                  if (widget.isHost)
                    buildHostControls(context, state.streamState),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget buildReactionPanel(BuildContext context, state) {
    if (!state.isJoined) return const SizedBox.shrink();

    return Positioned(
      bottom: 120,
      right: 10,
      left: 10,
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

  Widget buildHostControls(BuildContext context, state) {
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
}

  // Widget _buildPausedView() {
  //   return Container(
  //     color: Colors.black,
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             Icons.pause_circle_filled,
  //             color: Colors.orange,
  //             size: 80,
  //           ),
  //           const SizedBox(height: 20),
  //           const Text(
  //             'Stream Paused',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           const Text(
  //             'Your stream is paused while the app is in background',
  //             style: TextStyle(color: Colors.white70, fontSize: 16),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               setState(() {
  //                 _isInBackground = false;
  //               });
  //               context.read<LiveStreamCubit>().resumeStreaming();
  //             },
  //             child: const Text('Resume Stream'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }