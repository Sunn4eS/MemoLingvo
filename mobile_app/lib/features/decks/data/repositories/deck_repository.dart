import 'package:drift/drift.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class DeckRepository {
  final AppDatabase _db;

  DeckRepository(this._db);

  Stream<List<DeckWithCount>> watchDecksWithCount() => _db.watchDecksWithCardCount();

  Future<int> createDeck(String title, String? description) {
    return _db.insertDeck(
      DecksCompanion(
        title: Value(title),
        description: description != null
            ? Value(description)
            : Value.absent(),
      ),
    );
  }

  Future updateDeck(Deck deck) => _db.updateDeck(deck);
  
  Future updateDeckTitle(int id, String newTitle) {
    return (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
      DecksCompanion(title: Value(newTitle)),
    );
  }

  Future deleteDeck(int id) => _db.deleteDeck(id);
}
