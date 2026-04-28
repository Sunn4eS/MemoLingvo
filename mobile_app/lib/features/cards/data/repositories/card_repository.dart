import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class CardRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  CardRepository(this._db);

  Future<String?> getServerUserId(String email) => _db.getServerUserId(email);

  Future<void> updateCardProgress(String cardId, String userId, int quality) async {
    // 1. Получаем текущий прогресс из базы
    final currentProgress = await (_db.select(_db.cardProgress)
          ..where((t) => t.cardId.equals(cardId) & t.userId.equals(userId)))
        .getSingleOrNull();

    int repetitions = currentProgress?.repetitions ?? 0;
    double ef = currentProgress?.easinessFactor ?? 2.5;
    int interval = currentProgress?.interval ?? 0;

    // 2. Алгоритм интервального повторения (упрощенный SM-2)
    if (quality >= 3) {
      // Свайп вправо (хорошо выучили)
      repetitions += 1;
      if (repetitions == 1) {
        interval = 1;
      } else if (repetitions == 2) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
      
      // Повышаем фактор легкости
      ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      // Свайп влево (забыли)
      repetitions = 0;
      interval = 1;
      ef = ef - 0.8;
    }

    if (ef < 1.3) ef = 1.3;

    // Рассчитываем дату следующего повторения
    DateTime nextReview = DateTime.now().toUtc().add(Duration(days: interval));

    // 3. Сохраняем обновленные данные в БД
    await _db.into(_db.cardProgress).insertOnConflictUpdate(
      CardProgressCompanion.insert(
        cardId: cardId,
        userId: userId,
        nextReview: nextReview,
        easinessFactor: Value(ef),
        repetitions: Value(repetitions),
        interval: Value(interval),
        updateAt: DateTime.now().toUtc(),
        isDirty: const Value(true),
      )
    );
  }

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
        updateAt: Value(DateTime.now().toUtc()),
        isDirty: const Value(true),
      ),
    );
  }

  Stream<List<Card>> watchCards(String deckId) {
    return (_db.select(_db.cards)
      ..where((t) => t.deckId.equals(deckId))
      ..where((t) => t.isDeleted.equals(false)))
        .watch();
  }

  Future<void> deleteCard(String id) async {
    await (_db.update(_db.cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updateAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

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
        id: _uuid.v4(),
        deckId: deckId,
        word: word,
        translation: translation,
        transcription: transcription != null ? Value(transcription) : const Value.absent(),
        meaning: meaning,
        examples: examples != null ? Value(examples) : const Value.absent(),
        updateAt: DateTime.now().toUtc(),
        isDirty: const Value(true),
        isDeleted: const Value(false),
      ),
    );
  }
}