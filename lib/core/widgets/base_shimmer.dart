import 'package:flutter/material.dart';
import 'package:qtech_task/core/extensions/extensions.dart';
import 'package:shimmer/shimmer.dart';

class BaseShimmer extends StatelessWidget {
  final Widget child;

  const BaseShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: context.hintColor.withOpacity(.05),
      baseColor: context.hintColor.withOpacity(.2),
      child: child,
    );
  }
}
