import 'package:lingo_cards/features/cards/domain/entites/word_card.dart';

abstract class CardRepository {
  Stream<List<WordCard>> watchAllCards();

  Future<void> addCard(String original);
  Future<void> deleteCard(int id);

}