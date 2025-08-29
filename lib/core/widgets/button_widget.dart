import 'package:flutter/material.dart';
import 'package:qtech_task/core/extensions/extensions.dart';

import 'custom_loading.dart';


class ButtonWidget extends StatelessWidget {
  final String? title;
  final Widget? child, titleIcon;
  final void Function()? onPressed;
  final bool loading, enable, safeArea;
  final Color? backgroundColor, borderColor, textColor;
  final double? height, width, fontSize, radius;
  final List<Color>? gradientColors;
  const ButtonWidget(
    this.title, {
    super.key,
    this.onPressed,
    this.child,
    this.loading = false,
    this.backgroundColor,
    this.height,
    this.width,
    this.textColor,
    this.enable = true,
    this.safeArea = false,
    this.borderColor,
    this.fontSize,
    this.titleIcon,
    this.radius,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: safeArea,
      child: GestureDetector(
        onTap: () {
          unFocus();
          onPressed!();
        },
        child: Container(
          width: width,
          height: height ?? 53,
          decoration: BoxDecoration(
              color: backgroundColor ?? context.primaryColor,
              border: borderColor == null ? null : Border.all(color: borderColor!),
              borderRadius: BorderRadius.circular(radius ?? 12)),
          child: Row(
            mainAxisAlignment: loading ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              if (loading) CustomProgress(size: 15, color: (textColor ?? context.buttonTextColor).withOpacity(0.8)).paddingAll(start: 20),
              child ??
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: (() {
                        if (title?.isNotEmpty == true) {
                          return Row(
                            children: [
                              if (titleIcon != null) titleIcon!.paddingAll(end: 6),
                              Text(
                                title ?? "",
                                style: TextStyle(
                                  fontSize: fontSize ?? 16,
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                  color: (textColor ?? context.buttonTextColor).withOpacity((() {
                                    if ((textColor ?? context.buttonTextColor).opacity < 1) {
                                      return (textColor ?? context.buttonTextColor).opacity;
                                    } else if (!enable || loading) {
                                      return 0.4;
                                    } else {
                                      return 1.0;
                                    }
                                  })()),
                                ),
                                textAlign: TextAlign.center,
                              ).paddingAll(horizontal: 4),
                            ],
                          );
                        }
                      })(),
                    ),
                  ),
              if (loading) SizedBox(width: 15)
            ],
          ),
        ),
      ),
    );
  }
}

unFocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
