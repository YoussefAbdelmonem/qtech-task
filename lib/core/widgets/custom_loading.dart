

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qtech_task/core/extensions/extensions.dart';



class CustomProgress extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final double? value;
  final Color? backgroundColor;

  const CustomProgress({super.key, this.size, this.strokeWidth, this.color, this.backgroundColor, this.value});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(color: color ?? context.primaryColor, size: size ?? 35);
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomProgress(size: 25).center;
  }
}
