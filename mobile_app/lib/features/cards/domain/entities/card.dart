import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

enum LearningStatus {
  @JsonValue(0) newCard,    // Новая (еще не свайпали)
  @JsonValue(1) learning,   // В процессе (свайпнули влево)
  @JsonValue(2) mastered    // Выучена (свайпнули вправо)
}

@freezed
sealed class Card with _$Card {
  const factory Card({
    required String id,
    required String deckId,

    //Front
    required String word,
    String? transcription,

    //Back
    required String translation,
    String? meaning, 
    List<String>? examples,

    @Default(LearningStatus.newCard) LearningStatus status,
    @Default(0) int repetitions,
    DateTime? lastSeen,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) =>
      _$CardFromJson(json);
}