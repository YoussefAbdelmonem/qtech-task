import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/live_stream_cubit.dart';

class PausedVideoWidget extends StatefulWidget {
  const PausedVideoWidget({super.key, required this.isInBackground});
  final bool isInBackground;

  @override
  State<PausedVideoWidget> createState() => _PausedVideoWidgetState();
}

class _PausedVideoWidgetState extends State<PausedVideoWidget> {
  bool isInBackground = false;

  @override
  void initState() {
    super.initState();
    isInBackground = widget.isInBackground;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pause_circle_filled,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stream Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your stream is paused while the app is in background',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isInBackground = false;
                });
                context.read<LiveStreamCubit>().resumeStreaming();
              },
              child: const Text('Resume Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
