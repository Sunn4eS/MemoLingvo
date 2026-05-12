import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class CardRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  CardRepository(this._db);

  Future<String?> getServerUserId(String email) => _db.getServerUserId(email);

  Future<void> updateCardProgress(String cardId, String userId, int quality) async {
  final currentProgress = await (_db.select(_db.cardProgress)
        ..where((t) => t.cardId.equals(cardId) & t.userId.equals(userId)))
      .getSingleOrNull();

  int repetitions = currentProgress?.repetitions ?? 0;
  double ef = currentProgress?.easinessFactor ?? 2.5;
  int interval = currentProgress?.interval ?? 0;

  DateTime nextReview;

  if (quality >= 3) {
    // ЗНАЮ (Свайп вправо)
    repetitions += 1;
    if (repetitions == 1) {
      interval = 1;
    } else if (repetitions == 2) {
      interval = 6;
    } else {
      interval = (interval * ef).round();
    }
    ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (ef < 1.3) ef = 1.3;
    
    // Переносим на будущее (карточка исчезнет из колоды)
    nextReview = DateTime.now().toUtc().add(Duration(days: interval));
  } else {
    // НЕ ЗНАЮ (Свайп влево)
    repetitions = 0;
    interval = 0;
    ef = ef - 0.8;
    if (ef < 1.3) ef = 1.3;
    
    // Ставим дату "сейчас" (или 1 минуту назад), чтобы она ОСТАЛАСЬ в колоде
    nextReview = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
  }

  // 1. Обновляем прогресс
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

  // 2. Обновляем статус самой карточки (для красоты в профиле)
  // Если интервал > 0, значит мы ее отложили (mastered)
  // Если интервал == 0, значит мы ее еще учим (learning)
  await (_db.update(_db.cards)..where((t) => t.id.equals(cardId))).write(
    CardsCompanion(
      status: Value(interval > 0 ? LearningStatus.mastered : LearningStatus.learning),
      updateAt: Value(DateTime.now().toUtc()),
      isDirty: const Value(true),
    ),
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

  // В CardRepository
Stream<List<Card>> watchDueCards(String deckId, String userId) {
  final query = _db.select(_db.cards).join([
    leftOuterJoin(
      _db.cardProgress,
      _db.cardProgress.cardId.equalsExp(_db.cards.id) & 
      _db.cardProgress.userId.equals(userId),
    ),
  ]);

  query.where(_db.cards.deckId.equals(deckId));
  query.where(_db.cards.isDeleted.equals(false));

  // Условие: карточка должна быть в списке, если:
  // 1. У нее нет записи в прогрессе (она новая)
  // 2. Или ее время повторения НАСТУПИЛО (nextReview <= сейчас)
  query.where(
    _db.cardProgress.cardId.isNull() | 
    _db.cardProgress.nextReview.isSmallerOrEqualValue(DateTime.now().toUtc())
  );

  return query.watch().map((rows) {
    return rows.map((row) => row.readTable(_db.cards)).toList();
  });
}
Future<List<Card>> getDueCards(String deckId, String userId) async {
  final query = _db.select(_db.cards).join([
    leftOuterJoin(
      _db.cardProgress,
      _db.cardProgress.cardId.equalsExp(_db.cards.id) & 
      _db.cardProgress.userId.equals(userId),
    ),
  ]);

  query.where(_db.cards.deckId.equals(deckId));
  query.where(_db.cards.isDeleted.equals(false));
  query.where(
    _db.cardProgress.cardId.isNull() | 
    _db.cardProgress.nextReview.isSmallerOrEqualValue(DateTime.now().toUtc())
  );

  final rows = await query.get();
  return rows.map((row) => row.readTable(_db.cards)).toList();
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