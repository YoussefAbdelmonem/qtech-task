
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtech_task/features/live_stream/widgets/reaction_animation_cubit.dart';

class ReactionAnimationsWidget extends StatelessWidget {
  const ReactionAnimationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReactionAnimationCubit, ReactionAnimationState>(
      builder: (context, state) {
        return Stack(
          children: state.controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            final reaction = state.reactions[index];

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final slideAnimation = Tween<Offset>(
                  begin: Offset(
                    (index % 3 - 1) * 0.3,
                    1.0,
                  ),
                  end: Offset(
                    (index % 3 - 1) * 0.3,
                    -0.5,
                  ),
                ).animate(CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeOut,
                ));

                final scaleAnimation = Tween<double>(
                  begin: 0.5,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: controller,
                  curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
                ));

                final fadeAnimation = Tween<double>(
                  begin: 1.0,
                  end: 0.0,
                ).animate(CurvedAnimation(
                  parent: controller,
                  curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                ));

                return Positioned.fill(
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Center(
                      child: Transform.scale(
                        scale: scaleAnimation.value,
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  reaction.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  reaction.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}