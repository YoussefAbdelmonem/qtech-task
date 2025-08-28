import 'package:equatable/equatable.dart';

class Reaction extends Equatable {
  final String emoji;
  final String userName;
  final DateTime timestamp;
  final String id;

  const Reaction({
    required this.emoji,
    required this.userName,
    required this.timestamp,
    required this.id,
  });

  factory Reaction.fromMap(Map<dynamic, dynamic> map, String id) {
    return Reaction(
      emoji: map['emoji'] ?? '❤️',
      userName: map['userName'] ?? 'Anonymous',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'userName': userName,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [emoji, userName, timestamp, id];
}