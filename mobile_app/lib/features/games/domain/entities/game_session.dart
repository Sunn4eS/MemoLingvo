import 'package:equatable/equatable.dart';

class GameSession extends Equatable {
  final String id;
  final String userId;
  final String gameType;
  final String result;
  final int score;
  final int timeTakenSeconds;
  final int accuracyPercent;
  final DateTime playedAt;

  const GameSession({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.result,
    required this.score,
    required this.timeTakenSeconds,
    required this.accuracyPercent,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    gameType,
    result,
    score,
    timeTakenSeconds,
    accuracyPercent,
    playedAt,
  ];
}
