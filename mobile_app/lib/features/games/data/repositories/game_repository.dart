import 'package:drift/drift.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';

class GameRepository {
  final AppDatabase _db;
  final ApiClient _api;
  final _uuid = const Uuid();

  GameRepository(this._db, this._api);

  // Сохранить результат локально и отправить на сервер
  Future<void> saveGameResult({
    required String userId,
    required String gameType,
    required String result,
    required int score,
    required int timeTakenSeconds,
    required int accuracyPercent,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now().toUtc();

    // Локальное сохранение
    await _db.into(_db.gameSessions).insert(
      GameSessionsCompanion.insert(
        id: sessionId,
        userId: userId,
        gameType: gameType,
        result: result,
        score: score,
        timeTakenSeconds: timeTakenSeconds,
        accuracyPercent: accuracyPercent,
        playedAt: now,
        updateAt: now,
        isDirty: const Value(true),
      ),
    );

    // Отправка на сервер (пока заглушка)
    await _api.submitGameResult(
      userId: userId,
      gameType: gameType,
      result: result,
      score: score,
      timeTakenSeconds: timeTakenSeconds,
      accuracyPercent: accuracyPercent,
    );

    // Обновление опыта (заглушка: начисляем очки)
    final currentUser = await (_db.select(_db.usersTable)..where((t) => t.id.equals(userId))).getSingle();
    int newExp = currentUser.experience + score;
    int newRank = _calculateRank(newExp);
    await (_db.update(_db.usersTable)..where((t) => t.id.equals(userId))).write(
      UsersTableCompanion(
        experience: Value(newExp),
        rank: Value(newRank),
      ),
    );
  }

  int _calculateRank(int exp) {
    if (exp < 1000) return 0;
    if (exp < 3000) return 1;
    if (exp < 6000) return 2;
    if (exp < 10000) return 3;
    return 4;
  }

  // Получение истории игр пользователя
  Stream<List<GameSession>> watchSessions(String userId) {
    final query = _db.select(_db.gameSessions)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm(expression: t.playedAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  // Получение таблицы лидеров (с сервера или локально) – заглушка
  Future<List<UserRank>> getLeaderboard() async {
    // Вызов API с моком (в api_client)
    return _api.getLeaderboard();
  }

  // Получение текущего ранга пользователя
  Future<UserRank> getUserRank(String userId) async {
    final user = await (_db.select(_db.usersTable)..where((t) => t.id.equals(userId))).getSingle();
    return UserRank(
      userId: user.id,
      email: user.email,
      experience: user.experience,
      rank: user.rank,
    );
  }
}