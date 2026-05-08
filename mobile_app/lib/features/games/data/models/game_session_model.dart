import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_session_model.freezed.dart';
part 'game_session_model.g.dart';

@freezed
sealed class GameSessionModel with _$GameSessionModel {
  const factory GameSessionModel({
    required String id,
    required String userId,
    required String gameType,
    required String result,
    required int score,
    required int timeTakenSeconds,
    required int accuracyPercent,
    required DateTime playedAt,
  }) = _GameSessionModel;

  factory GameSessionModel.fromJson(Map<String, dynamic> json) =>
      _$GameSessionModelFromJson(json);
}