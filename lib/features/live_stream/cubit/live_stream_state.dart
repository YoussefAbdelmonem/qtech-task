import 'package:equatable/equatable.dart';

import '../live_stream_screen.dart';
import '../model/reactions_model.dart';
import '../model/stream_state_model.dart';

abstract class LiveStreamState extends Equatable {
  const LiveStreamState();

  @override
  List<Object?> get props => [];
}

class LiveStreamInitial extends LiveStreamState {}

class LiveStreamLoading extends LiveStreamState {}

class LiveStreamConnected extends LiveStreamState {
  final StreamStateModel streamState;

  const LiveStreamConnected(this.streamState);

  @override
  List<Object?> get props => [streamState];
}

class LiveStreamError extends LiveStreamState {
  final String message;

  const LiveStreamError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReactionReceived extends LiveStreamState {
  final Reaction reaction;

  const ReactionReceived(this.reaction);

  @override
  List<Object?> get props => [reaction];
}