import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'dart:convert';
import 'package:memo_lingvo/core/network/api_client.dart';

class DeckRepository {
  final AppDatabase _db;

  DeckRepository(this._db);

  final _uuid = const Uuid();

  Stream<List<DeckWithCount>> watchDecksWithCount(String userId) =>
      _db.watchDecksWithCardCount(userId);

  Future<String?> getServerUserId(String email) => _db.getServerUserId(email);

  Future<void> importDeck(String code, String currentUserId) async {
    final parts = code.split('_');
    if (parts.length != 2) throw Exception("Неверный формат кода");

    final sourceUserId = parts[0];
    final sourceDeckId = parts[1];

    final api = ApiClient();

    final serverDecks = await api.getDecks(sourceUserId);
    final deckMap = serverDecks.firstWhere(
      (d) => d['deckID'] == sourceDeckId,
      orElse: () => <String, dynamic>{},
    );

    if (deckMap.isEmpty) throw Exception("Колода не найдена или удалена");

    final serverCards = await api.getCards(sourceUserId);
    final deckCards = serverCards
        .where((c) => c['deckID'] == sourceDeckId)
        .toList();

    final newDeckId = _uuid.v4();
    await _db
        .into(_db.decks)
        .insert(
          DecksCompanion.insert(
            id: newDeckId,
            userId: currentUserId,
            title: deckMap['title'] + " (Импорт)",
            description: deckMap['description'] != null
                ? Value(deckMap['description'])
                : const Value.absent(),
            updateAt: DateTime.now().toUtc(),
            isDirty: const Value(true),
            isDeleted: const Value(false),
          ),
        );

    for (var c in deckCards) {
      List<String>? parsedExamples;
      if (c['examples'] != null && c['examples'].toString().isNotEmpty) {
        try {
          parsedExamples = List<String>.from(jsonDecode(c['examples']));
        } catch (_) {}
      }

      await _db
          .into(_db.cards)
          .insert(
            CardsCompanion.insert(
              id: _uuid.v4(),
              deckId: newDeckId,
              word: c['word'],
              translation: c['translation'],
              transcription: c['transcription'] != null
                  ? Value(c['transcription'])
                  : const Value.absent(),
              meaning: c['meaning'] ?? '',
              examples: parsedExamples != null
                  ? Value(parsedExamples)
                  : const Value.absent(),
              updateAt: DateTime.now().toUtc(),
              isDirty: const Value(true),
              isDeleted: const Value(false),
            ),
          );
    }
  }

  Future<void> createDeck(
    String title,
    String? description,
    String currentUserId,
  ) async {
    await _db
        .into(_db.decks)
        .insert(
          DecksCompanion.insert(
            id: _uuid.v4(),
            userId: currentUserId,
            title: title,
            description: description != null
                ? Value(description)
                : const Value.absent(),
            updateAt: DateTime.now().toUtc(),
            isDirty: const Value(true),
            isDeleted: const Value(false),
          ),
        );
  }

  Future<void> deleteDeck(String id) async {
    await (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
      DecksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updateAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> updateDeck(Deck deck) async {
    await _db
        .update(_db.decks)
        .replace(
          deck.copyWith(isDirty: true, updateAt: DateTime.now().toUtc()),
        );
  }
}
