import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

enum LearningStatus {
  @JsonValue(0)
  newCard,
  @JsonValue(1)
  learning,
  @JsonValue(2)
  mastered,
}

@freezed
sealed class Card with _$Card {
  const factory Card({
    required String id,
    required String deckId,

    required String word,
    String? transcription,

    required String translation,
    String? meaning,
    List<String>? examples,

    @Default(LearningStatus.newCard) LearningStatus status,
    @Default(0) int repetitions,
    DateTime? lastSeen,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}
