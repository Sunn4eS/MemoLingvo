import 'dart:convert';
import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
//import 'package:memo_lingvo/features/decks/domain/entities/deck.dart';

part 'app_database.g.dart';

enum LearningStatus {
  newCard, // 0
  learning, // 1
  mastered, // 2
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
}

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Привязка к колоде
  IntColumn get deckId =>
      integer().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get word => text()();
  TextColumn get translation => text()();
  TextColumn get transcription => text().nullable()();
  TextColumn get meaning => text().nullable()();

  TextColumn get examples =>
      text().map(const StringListConverter()).nullable()();

  IntColumn get status => intEnum<LearningStatus>().withDefault(
    Constant(LearningStatus.newCard.index),
  )();

  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeen => dateTime().nullable()();
}

@DriftDatabase(tables: [Decks, Cards])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Это обязательно для работы OperationAction.cascade
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  //Deck
  Stream<List<Deck>> watchAllDecks() => select(decks).watch();
  Future<int> insertDeck(DecksCompanion deck) => into(decks).insert(deck);
  Future updateDeck(Deck deck) => update(decks).replace(deck);
  Future deleteDeck(int id) =>
      (delete(decks)..where((t) => t.id.equals(id))).go();




  //Card
  Stream<List<Card>> watchCardsInDeck(int deckId) {
    return (select(cards)..where((t) => t.deckId.equals(deckId))).watch();
  }

  Future updateCardStatus(int cardId, LearningStatus newStatus) {
    return (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(
        status: Value(newStatus),
        lastSeen: Value(DateTime.now()),
        repetitions: Value(1),
      ),
    );
  }

  Future<int> insertCard(CardsCompanion card) => into(cards).insert(card);
  Future updateCard(Card card) => update(cards).replace(card);
  Future deleteCard(int id) =>
      (delete(cards)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
