import 'dart:convert';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';
import 'package:drift/drift.dart';

class SyncService {
  final AppDatabase _db;
  final ApiClient _api;

  SyncService(this._db, this._api);

  Future<void> pushDirtyData() async {
    print("🚀 Начинаю синхронизацию (Push)...");
    
    

    await _syncDecks();

    await _syncCards();

    await _syncProgress();

    print("✅ Синхронизация завершена!");
  }

  /*Future<void> _syncUser() async {
    // Берем пользователя из локальной БД
    final users = await _db.select(_db.usersTable).get();
    if (users.isEmpty) return;

    final currentUser = users.first;

    // Собираем данные точно по модели C# User
    final data = {
      'userID': currentUser.id,
      'email': currentUser.email,
      'passwordHash': 'FirebaseAuth', // Заглушка, т.к. пароль хранится в Firebase, но C# требует это поле
      'createdAt': currentUser.createdAt.toUtc().toIso8601String(),
    };

    // Отправляем на сервер (даже если он уже там есть, пусть сервер его обновит/проигнорирует)
    await _api.pushUser(data);
  }*/

  Future<void> _syncDecks() async {
    final dirtyDecks = await (_db.select(_db.decks)..where((t) => t.isDirty.equals(true))).get();
    
    if (dirtyDecks.isEmpty) return;

    final List<Map<String, dynamic>> payload = dirtyDecks.map((deck) => {
      'deckID': deck.id,
      'userID': deck.userId,
      'title': deck.title,
      'description': deck.description,
      'updateAt': deck.updateAt.toUtc().toIso8601String(),
      'isDeleted': deck.isDeleted,
    }).toList();

    final success = await _api.pushDeck(payload);

    if (success) {
      for (final deck in dirtyDecks) {
        await (_db.update(_db.decks)..where((t) => t.id.equals(deck.id)))
            .write(const DecksCompanion(isDirty: Value(false)));
      }
    }
  }

  Future<void> _syncCards() async {
    final dirtyCards = await (_db.select(_db.cards)..where((t) => t.isDirty.equals(true))).get();
    
    if (dirtyCards.isEmpty) return;

    final List<Map<String, dynamic>> payload = dirtyCards.map((card) => {
      'cardID': card.id,
      'deckID': card.deckId,
      'word': card.word,
      'translation': card.translation,
      'transcription': card.transcription,
      'meaning': card.meaning,
      'examples': card.examples != null ? jsonEncode(card.examples) : null, 
      'updateAt': card.updateAt.toUtc().toIso8601String(),
      'isDeleted': card.isDeleted,
    }).toList();

    final success = await _api.pushCard(payload);
    
    if (success) {
      for (final card in dirtyCards) {
        await (_db.update(_db.cards)..where((t) => t.id.equals(card.id)))
            .write(const CardsCompanion(isDirty: Value(false)));
      }
    }
  }

  Future<void> _syncProgress() async {
    final dirtyProgress = await (_db.select(_db.cardProgress)..where((t) => t.isDirty.equals(true))).get();
    
    if (dirtyProgress.isEmpty) return;

    final List<Map<String, dynamic>> payload = dirtyProgress.map((progress) => {
      'cardID': progress.cardId,
      'userID': progress.userId,
      'nextReview': progress.nextReview.toUtc().toIso8601String(),
      'easinessFactor': progress.easinessFactor,
      'repetitions': progress.repetitions,
      'interval': progress.interval,
      'updateAt': progress.updateAt.toUtc().toIso8601String(),
    }).toList();

    final success = await _api.pushProgress(payload);
    
    if (success) {
      for (final progress in dirtyProgress) {
        await (_db.update(_db.cardProgress)
              ..where((t) => t.cardId.equals(progress.cardId) & t.userId.equals(progress.userId)))
            .write(const CardProgressCompanion(isDirty: Value(false)));
      }
    }
  }
  // Главный метод для ЗАГРУЗКИ данных с сервера
  // Главный метод для ЗАГРУЗКИ данных с сервера (Сравнение по времени!)
  Future<void> pullServerData(String currentUserId) async {
    print("📥 Начинаю скачивание данных с сервера (Pull)...");

    // 1. СКАЧИВАЕМ КОЛОДЫ
    final serverDecks = await _api.getDecks(currentUserId);
    for (var deckMap in serverDecks) {
      final String serverId = deckMap['deckID'];
      final DateTime serverUpdateAt = DateTime.parse(deckMap['updateAt']).toUtc();

      // Ищем колоду у нас в базе
      final localDeck = await (_db.select(_db.decks)..where((t) => t.id.equals(serverId))).getSingleOrNull();

      // Если колоды нет локально ИЛИ серверная версия новее
      if (localDeck == null || serverUpdateAt.isAfter(localDeck.updateAt)) {
        await _db.into(_db.decks).insertOnConflictUpdate(
          DecksCompanion.insert(
            id: serverId, 
            userId: deckMap['userID'],
            title: deckMap['title'],
            description: deckMap['description'] != null ? Value(deckMap['description']) : const Value.absent(),
            updateAt: serverUpdateAt,
            isDeleted: Value(deckMap['isDeleted'] ?? false),
            isDirty: const Value(false), // Скачали с сервера, значит чистое
          )
        );
      }
    }

    // 2. СКАЧИВАЕМ КАРТОЧКИ
    final serverCards = await _api.getCards(currentUserId);
    for (var cardMap in serverCards) {
      final String serverId = cardMap['cardID'];
      final DateTime serverUpdateAt = DateTime.parse(cardMap['updateAt']).toUtc();

      final localCard = await (_db.select(_db.cards)..where((t) => t.id.equals(serverId))).getSingleOrNull();

      if (localCard == null || serverUpdateAt.isAfter(localCard.updateAt)) {
        List<String>? parsedExamples;
        if (cardMap['examples'] != null && cardMap['examples'].toString().isNotEmpty) {
          try {
            // Пытаемся распарсить правильный JSON массив
            parsedExamples = List<String>.from(jsonDecode(cardMap['examples']));
          } catch (e) {
            // Если с бэкенда пришел мусор из Swagger (например, слово "string")
            print("⚠️ Ошибка парсинга examples (пришел мусор с сервера). Игнорируем.");
            parsedExamples = []; 
          }
        }

        await _db.into(_db.cards).insertOnConflictUpdate(
          CardsCompanion.insert(
            id: serverId,
            deckId: cardMap['deckID'],
            word: cardMap['word'],
            translation: cardMap['translation'],
            transcription: cardMap['transcription'] != null ? Value(cardMap['transcription']) : const Value.absent(),
            meaning: cardMap['meaning'],
            examples: parsedExamples != null ? Value(parsedExamples) : const Value.absent(),
            updateAt: serverUpdateAt,
            isDeleted: Value(cardMap['isDeleted'] ?? false),
            isDirty: const Value(false),
          )
        );
      }
    }

    // 3. СКАЧИВАЕМ ПРОГРЕСС ИЗУЧЕНИЯ (SM-2)
    final serverProgressList = await _api.getProgress(currentUserId);
    for (var progressMap in serverProgressList) {
      final String serverCardId = progressMap['cardID'];
      final String serverUserId = progressMap['userID'];
      final DateTime serverUpdateAt = DateTime.parse(progressMap['updateAt']).toUtc();

      // Ищем прогресс у нас в базе (здесь СОСТАВНОЙ КЛЮЧ: ищем по cardId И userId)
      final localProgress = await (_db.select(_db.cardProgress)
            ..where((t) => t.cardId.equals(serverCardId) & t.userId.equals(serverUserId)))
          .getSingleOrNull();

      if (localProgress == null || serverUpdateAt.isAfter(localProgress.updateAt)) {
        await _db.into(_db.cardProgress).insertOnConflictUpdate(
          CardProgressCompanion.insert(
            cardId: serverCardId,
            userId: serverUserId,
            nextReview: DateTime.parse(progressMap['nextReview']).toUtc(),
            // Используем num для безопасной конвертации int/double из JSON
            easinessFactor: Value((progressMap['easinessFactor'] as num).toDouble()), 
            repetitions: Value((progressMap['repetitions'] as num).toInt()),
            interval: Value((progressMap['interval'] as num).toInt()),
            updateAt: serverUpdateAt,
            isDirty: const Value(false),
          )
        );
      }
    }

    print("✅ Скачивание завершено!");
  }
}