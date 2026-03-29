import 'package:drift/drift.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

class DeckRepository {
  final AppDatabase _db;
  final AuthRepository _auth;

  DeckRepository(this._db, this._auth);

  String get _userId => _auth.currentUserId ?? 'guest';

  Stream<List<DeckWithCount>> watchDecksWithCount() {
    return _auth.userStatus.switchMap((user) {
      final userId = user?.uid ?? 'guest';
      return _db.watchDecksWithCardCount(userId);
    });
  }

  Future<int> createDeck(String title, String? description) {
    return _db.insertDeck(
      DecksCompanion(
        userId: Value(_userId),
        title: Value(title),
        description: description != null ? Value(description) : Value.absent(),
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
