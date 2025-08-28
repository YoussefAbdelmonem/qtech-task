import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/reactions_model.dart';

class ReactionAnimationState {
  final List<AnimationController> controllers;
  final List<Reaction> reactions;

  const ReactionAnimationState({
    this.controllers = const [],
    this.reactions = const [],
  });

  ReactionAnimationState copyWith({
    List<AnimationController>? controllers,
    List<Reaction>? reactions,
  }) {
    return ReactionAnimationState(
      controllers: controllers ?? this.controllers,
      reactions: reactions ?? this.reactions,
    );
  }
}

class ReactionAnimationCubit extends Cubit<ReactionAnimationState> {
  final TickerProvider vsync;

  ReactionAnimationCubit(this.vsync) : super(const ReactionAnimationState());

  void addReaction(Reaction reaction) {
    final controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    );

    final newControllers = List<AnimationController>.from(state.controllers)..add(controller);
    final newReactions = List<Reaction>.from(state.reactions)..add(reaction);

    emit(state.copyWith(
      controllers: newControllers,
      reactions: newReactions,
    ));

    controller.forward().then((_) {
      final index = state.controllers.indexOf(controller);
      if (index != -1) {
        final updatedControllers = List<AnimationController>.from(state.controllers)..removeAt(index);
        final updatedReactions = List<Reaction>.from(state.reactions)..removeAt(index);
        
        emit(state.copyWith(
          controllers: updatedControllers,
          reactions: updatedReactions,
        ));
        
        controller.dispose();
      }
    });
  }

  @override
  Future<void> close() {
    for (final controller in state.controllers) {
      controller.dispose();
    }
    return super.close();
  }
}