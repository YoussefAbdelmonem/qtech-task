import 'package:equatable/equatable.dart';

import '../../../core/extensions/enums.dart';
import '../model/reactions_model.dart';
import '../model/stream_state_model.dart';

class LiveStreamState extends Equatable {
  final RequestState liveStramStatus, reactionStatus, leaveStreamStatus;
  final StreamStateModel? streamState;
  final String errorMessage;
  final Reaction? latestReaction;

  const LiveStreamState({
    this.liveStramStatus = RequestState.initial,
    this.streamState,
    this.errorMessage = '',
    this.latestReaction,
    this.reactionStatus = RequestState.initial,
    this.leaveStreamStatus = RequestState.initial,
  });

  LiveStreamState copyWith({
    RequestState? liveStramStatus,
    StreamStateModel? streamState,
    String? errorMessage,
    Reaction? latestReaction,
    RequestState? reactionStatus,
    RequestState? leaveStreamStatus,
  }) {
    return LiveStreamState(
      liveStramStatus: liveStramStatus ?? this.liveStramStatus,
      streamState: streamState ?? this.streamState,
      errorMessage: errorMessage ?? this.errorMessage,
      latestReaction: latestReaction ?? this.latestReaction,
      reactionStatus: reactionStatus ?? this.reactionStatus,
      leaveStreamStatus: leaveStreamStatus ?? this.leaveStreamStatus,
    );
  }

  @override
  List<Object?> get props => [
    liveStramStatus,
    streamState,
    errorMessage,
    latestReaction,
    reactionStatus,
    leaveStreamStatus,
  ];
}
