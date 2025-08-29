import 'package:equatable/equatable.dart';
import 'package:qtech_task/core/extensions/enums.dart';




class PreJoinState extends Equatable {
  final RequestState status;
  final FirebaseConnectionStatus firebaseStatus;
  final ChannelCheckStatus channelStatus;
  final String? errorMessage;
  final bool isHost;
  final String? channelName;
  final String? userName;

  const PreJoinState({
    this.status = RequestState.initial,
    this.firebaseStatus = FirebaseConnectionStatus.disconnected,
    this.channelStatus = ChannelCheckStatus.initial,
    this.errorMessage,
    this.isHost = false,
    this.channelName,
    this.userName,
  });

  PreJoinState copyWith({
    RequestState? status,
    FirebaseConnectionStatus? firebaseStatus,
    ChannelCheckStatus? channelStatus,
    String? errorMessage,
    bool? isHost,
    String? channelName,
    String? userName,
  }) {
    return PreJoinState(
      status: status ?? this.status,
      firebaseStatus: firebaseStatus ?? this.firebaseStatus,
      channelStatus: channelStatus ?? this.channelStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isHost: isHost ?? this.isHost,
      channelName: channelName ?? this.channelName,
      userName: userName ?? this.userName,
    );
  }

  // Helper getters
  bool get isFirebaseConnected => firebaseStatus == FirebaseConnectionStatus.connected;
  bool get isLoading => status == RequestState.loading;
  bool get hasError => status == RequestState.error || firebaseStatus == FirebaseConnectionStatus.error;
  bool get canJoinChannel => isFirebaseConnected && !isLoading;

  @override
  List<Object?> get props => [
        status,
        firebaseStatus,
        channelStatus,
        errorMessage,
        isHost,
        channelName,
        userName,
      ];
}