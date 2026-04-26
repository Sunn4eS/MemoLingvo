import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class DeckRepository {
  final AppDatabase _db;
  
  DeckRepository(this._db);

  // Для генерации ID
  final _uuid = const Uuid();

  // Передаем userId в БД
  Stream<List<DeckWithCount>> watchDecksWithCount(String userId) => _db.watchDecksWithCardCount(userId);

  Future<String?> getServerUserId(String email) => _db.getServerUserId(email);

  Future<void> createDeck(String title, String? description, String currentUserId) async {
    await _db.into(_db.decks).insert(
      DecksCompanion.insert(
        id: _uuid.v4(), // Генерируем уникальный ID строкой
        userId: currentUserId, // UID из Firebase
        title: title,
        description: description != null ? Value(description) : const Value.absent(),
        updateAt: DateTime.now().toUtc(), // ВРЕМЯ ВСЕГДА UTC!
        isDirty: const Value(true), // Отмечаем для отправки на сервер
        isDeleted: const Value(false),
      ),
    );
  }

  // Мягкое удаление! Не удаляем строку, а прячем
  Future<void> deleteDeck(String id) async {
    await (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
      DecksCompanion(
        isDeleted: const Value(true), // Прячем
        isDirty: const Value(true),   // Отмечаем, чтобы сервер тоже удалил
        updateAt: Value(DateTime.now().toUtc()),
      ),
    );
   }

   Future<void> updateDeck(Deck deck) async {
    await _db.update(_db.decks).replace(
      deck.copyWith(
        isDirty: true, 
        updateAt: DateTime.now().toUtc()
      )
    );
  }
}