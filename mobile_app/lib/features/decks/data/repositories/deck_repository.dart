import 'package:drift/drift.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class DeckRepository {
  final AppDatabase _db;

  DeckRepository(this._db);

  Stream<List<Deck>> watchDecks() => _db.watchAllDecks();

  Future<int> createDeck(String title, String? description) {
    return _db.insertDeck(
      DecksCompanion(
        title: Value(title),
        description: description != null
            ? Value(description)
            : const Value.absent(),
      ),
    );
  }

  Future updateDeck(Deck deck) => _db.updateDeck(deck);

  Future deleteDeck(int id) => _db.deleteDeck(id);
}
