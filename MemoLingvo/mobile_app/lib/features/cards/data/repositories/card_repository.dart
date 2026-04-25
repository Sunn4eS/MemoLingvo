import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class CardRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  CardRepository(this._db);

  Future<String?> getServerUserId(String email) => _db.getServerUserId(email);

  // Функция-заглушка для прогресса, как просил бэкендер!
  Future<void> updateCardProgress(String cardId, String userId, int quality) async {
    //quality: 5 - легкая, 1 - сложная
    //ПОКА ЧТО: просто обновляем дату следующего повторения на завтра
    DateTime nextReview = DateTime.now().toUtc().add(const Duration(days: 1));

    await _db.into(_db.cardProgress).insertOnConflictUpdate(
      CardProgressCompanion.insert(
        cardId: cardId,
        userId: userId,
        nextReview: nextReview,
        updateAt: DateTime.now().toUtc(),
        isDirty: const Value(true), // Помечаем для синхронизации
      )
    );
  }

  // Метод редактирования карточки
  Future<void> updateCard({
    required String id,
    required String word,
    required String translation,
    String? transcription,
    required String meaning,
    List<String>? examples,
  }) async {
    await (_db.update(_db.cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(
        word: Value(word),
        translation: Value(translation),
        transcription: Value(transcription),
        meaning: Value(meaning),
        examples: Value(examples),
        updateAt: Value(DateTime.now().toUtc()), // Ставим свежее время
        isDirty: const Value(true), // Отмечаем, что нужно отправить на сервер
      ),
    );
  }
  // Возвращаем метод просмотра карточек
  Stream<List<Card>> watchCards(String deckId) {
    return (_db.select(_db.cards)
      ..where((t) => t.deckId.equals(deckId))
      ..where((t) => t.isDeleted.equals(false))) // Не показываем удаленные
        .watch();
  }

  // Возвращаем метод удаления карточки (теперь "мягкое" удаление для сервера)
  Future<void> deleteCard(String id) async {
    await (_db.update(_db.cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(
        isDeleted: const Value(true), // Прячем
        isDirty: const Value(true),   // Отправляем на сервер команду удалить
        updateAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
  // Метод добавления новой карточки
  Future<void> addCard({
    required String deckId,
    required String word,
    required String translation,
    String? transcription,
    required String meaning,
    List<String>? examples,
  }) async {
    await _db.into(_db.cards).insert(
      CardsCompanion.insert(
        id: _uuid.v4(), // Генерируем UUID
        deckId: deckId,
        word: word,
        translation: translation,
        transcription: transcription != null ? Value(transcription) : const Value.absent(),
        meaning: meaning,
        examples: examples != null ? Value(examples) : const Value.absent(),
        updateAt: DateTime.now().toUtc(), // Обязательно UTC
        isDirty: const Value(true),       // Отправляем на сервер
        isDeleted: const Value(false),
      ),
    );
  }
}