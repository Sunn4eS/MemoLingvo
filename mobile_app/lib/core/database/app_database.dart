import 'dart:convert';
import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

enum LearningStatus {
  newCard, // 0
  learning, // 1
  mastered, // 2
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) => (jsonDecode(fromDb) as List).cast<String>();
  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class UsersTable extends Table {
  TextColumn get id => text()(); 
  TextColumn get email => text()();
  DateTimeColumn get createdAt => dateTime()();
 
  //TODO Backend User Table
  IntColumn get rank => integer().withDefault(const Constant(0))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

//TODO Game Sessions
class GameSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UsersTable, #id)();
  TextColumn get gameType => text()();    
  TextColumn get result => text()();      
  IntColumn get score => integer()();     
  IntColumn get timeTakenSeconds => integer()(); 
  IntColumn get accuracyPercent => integer()();  
  DateTimeColumn get playedAt => dateTime()();
  
  DateTimeColumn get updateAt => dateTime()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. ТАБЛИЦА DECKS
class Decks extends Table {
  TextColumn get id => text()(); 
  TextColumn get userId => text().references(UsersTable, #id)(); 
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  
  // Поля синхронизации
  DateTimeColumn get updateAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. ТАБЛИЦА CARDS
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id, onDelete: KeyAction.cascade)();
  
  TextColumn get word => text()();
  TextColumn get translation => text()();
  TextColumn get transcription => text().nullable()();
  TextColumn get meaning => text()();
  TextColumn get examples => text().map(const StringListConverter()).nullable()();

  // Поля синхронизации
  DateTimeColumn get updateAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  //Поле статуса
  IntColumn get status => intEnum<LearningStatus>().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. ТАБЛИЦА PROGRESS (SM-2)
class CardProgress extends Table {
  TextColumn get cardId => text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().references(UsersTable, #id)();
  
  DateTimeColumn get nextReview => dateTime()();
  RealColumn get easinessFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  
  // Поля синхронизации
  DateTimeColumn get updateAt => dateTime()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {cardId, userId}; // Составной ключ
}

// Класс для UI
class DeckWithCount {
  final Deck deck;
  final int cardCount;
  DeckWithCount(this.deck, this.cardCount);
}

@DriftDatabase(tables: [UsersTable, Decks, Cards, CardProgress, GameSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Добавляем таблицу game_sessions
        await m.createTable(gameSessions);
        // Добавляем колонки в users_table
        await m.addColumn(usersTable, usersTable.experience);
        await m.addColumn(usersTable, usersTable.rank);
      }
    },
  );




  Future<String?> getServerUserId(String email) async {
    final user = await (select(usersTable)..where((t) => t.email.equals(email))).getSingleOrNull();
    return user?.id;
  }

 // Получить колоды только текущего пользователя!
  Stream<List<DeckWithCount>> watchDecksWithCardCount(String currentUserId) {
    final countColumn = cards.id.count();
    
    // ДОБАВИЛИ ФИЛЬТР ПО userId
    final query = select(decks)..where((t) => t.isDeleted.equals(false) & t.userId.equals(currentUserId));

    final joinedQuery = query.join([
      leftOuterJoin(cards, cards.deckId.equalsExp(decks.id) & cards.isDeleted.equals(false))
    ]);

    joinedQuery.groupBy([decks.id]);
    joinedQuery.addColumns([countColumn]);

    return joinedQuery.watch().map((rows) {
      return rows.map((row) {
        return DeckWithCount(row.readTable(decks), row.read(countColumn) ?? 0);
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}