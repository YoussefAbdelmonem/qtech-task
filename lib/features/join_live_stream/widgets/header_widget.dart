import 'package:flutter/material.dart';
import 'package:qtech_task/core/extensions/extensions.dart';

import '../../../core/widgets/custom_image.dart';

class AppHeaderWidget extends StatelessWidget {
  const AppHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomImage("assets/lottie/welcome.json", height: 150),

        const SizedBox(height: 40),

        Text(
          'Join Live Stream',
          style: context.boldText.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Enter your details to join or create a live stream',
          style: context.mediumBody.copyWith(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
