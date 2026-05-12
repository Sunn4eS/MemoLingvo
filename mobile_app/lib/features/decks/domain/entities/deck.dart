import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

@freezed
sealed class Deck with _$Deck {
  const factory Deck({
    required String id,
    required String title,
    String? description,
    @Default(0) int cardsCount,
    @Default(0) int learnedCount,
  }) = _Deck;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
}
