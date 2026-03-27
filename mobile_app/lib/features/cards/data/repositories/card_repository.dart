import 'package:drift/drift.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class CardRepository {
  final AppDatabase _db;

  CardRepository(this._db);

  Stream<List<Card>> watchAllCards() => _db.select(_db.cards).watch();

  Stream<List<Card>> watchMasteredCards() {
    return (_db.select(
      _db.cards,
    )..where((t) => t.status.equals(LearningStatus.mastered.index))).watch();
  }

  Stream<List<Card>> watchCards(int deckId) => _db.watchCardsInDeck(deckId);

  Future<int> addCard({
    required int deckId,
    required String word,
    required String translation,
    String? transcription,
    String? meaning,
    List<String>? examples,
  }) {
    return _db.insertCard(
      CardsCompanion(
        deckId: Value(deckId),
        word: Value(word),
        translation: Value(translation),
        transcription: transcription != null
            ? Value(transcription)
            : const Value.absent(),
        meaning: meaning != null ? Value(meaning) : const Value.absent(),
        examples: examples != null ? Value(examples) : const Value.absent(),
      ),
    );
  }

  Future updateStatus(int cardId, LearningStatus status) {
    return _db.updateCardStatus(cardId, status);
  }

  Future deleteCard(int id) {
    return _db.deleteCard(id);
  }

  Future<bool> updateCard(Card card) {
    return _db.update(_db.cards).replace(card);
  }
}
