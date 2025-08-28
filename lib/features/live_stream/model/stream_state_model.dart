import 'package:equatable/equatable.dart';

class StreamStateModel extends Equatable {
  final bool isJoined;
  final bool isInitialized;
  final String status;
  final int remoteUid;
  final int viewerCount;
  final Map<String, dynamic> guests;
  final bool isMuted;
  final bool isCameraOff;

  const StreamStateModel({
    this.isJoined = false,
    this.isInitialized = false,
    this.status = "",
    this.remoteUid = 0,
    this.viewerCount = 0,
    this.guests = const {},
    this.isMuted = false,
    this.isCameraOff = false,
  });

  StreamStateModel copyWith({
    bool? isJoined,
    bool? isInitialized,
    String? status,
    int? remoteUid,
    int? viewerCount,
    Map<String, dynamic>? guests,
    bool? isMuted,
    bool? isCameraOff,
  }) {
    return StreamStateModel(
      isJoined: isJoined ?? this.isJoined,
      isInitialized: isInitialized ?? this.isInitialized,
      status: status ?? this.status,
      remoteUid: remoteUid ?? this.remoteUid,
      viewerCount: viewerCount ?? this.viewerCount,
      guests: guests ?? this.guests,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
    );
  }

  @override
  List<Object?> get props => [
        isJoined,
        isInitialized,
        status,
        remoteUid,
        viewerCount,
        guests,
        isMuted,
        isCameraOff,
      ];
}