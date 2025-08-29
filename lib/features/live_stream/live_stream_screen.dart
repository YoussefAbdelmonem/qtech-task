import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/agora_service.dart';
import 'cubit/live_stream_cubit.dart';
import 'repo/firebase_repo_data.dart';
import 'widgets/live_view.dart';
import 'widgets/reaction_animation_cubit.dart';

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
              LiveStreamCubit(LiveStreamRepository(), AgoraService())
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
