import 'package:flutter/material.dart';
import 'package:qtech_task/core/widgets/button_widget.dart';

import 'custom_image.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final Function onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomImage("assets/lottie/error_lottie.json", width: 250, height: 250),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ButtonWidget("Retry", onPressed: onRetry()),
      ],
    );
  }
}
