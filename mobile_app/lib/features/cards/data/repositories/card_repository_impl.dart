import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lingo_cards/features/cards/data/datasources/dictionary_api.dart';
import 'package:lingo_cards/features/cards/data/datasources/local_db.dart';
import 'package:lingo_cards/features/cards/domain/repositories/card_repository.dart';
import 'package:drift/drift.dart' as dbDrift;

import '../../domain/entites/word_card.dart';

class CardRepositoryImpl implements CardRepository {
  final AppDatabase db;
  final DictionaryApi api;

  CardRepositoryImpl(this.db, this.api);

  @override
  Stream<List<WordCard>> watchAllCards() {
    return db.watchWords().map((rows)
    => rows.map((row)
    => WordCard(
        id: row.id,
        original: row.original,
        translated: row.translated,
        example: row.example
    )).toList());
  }

  @override
  Future<void> addCard(String originalWord) async {
    String translatedText = "Нет переводов";
    String? exampleText;

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final wordDefinition = await api.fetchDefinition(originalWord);
        if (wordDefinition != null) {
          translatedText = wordDefinition;
          exampleText = "Fetched from API";
        }
      } catch (e) {

      }
    }

    await db.insertWord(WordTablesCompanion(
      original: dbDrift.Value(originalWord),
      translated: dbDrift.Value(translatedText),
      example: dbDrift.Value(exampleText),
    ));
  }

  @override
  Future<void> deleteCard(int id) async {
    await db.deleteWord(id);
  }

}