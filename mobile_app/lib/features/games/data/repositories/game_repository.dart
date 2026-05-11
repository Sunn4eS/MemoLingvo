import 'dart:math';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';

class GameRepository {
  final AppDatabase _db;
  final ApiClient _api;
  final _uuid = const Uuid();

  GameRepository(this._db, this._api);

  /// Публичный доступ к БД (нужен для получения serverUserId)
  AppDatabase get database => _db;

  /// Сохранить результат игры локально и отправить на сервер
  Future<void> saveGameResult({
    required String userId, // serverUserId
    required String gameType,
    required String result,
    required int score,
    required int timeTakenSeconds,
    required int accuracyPercent,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now().toUtc();

    // 1. Сохраняем в локальную БД
    await _db
        .into(_db.gameSessions)
        .insert(
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

    // 2. Отправляем на сервер (заглушка)
    await _api.submitGameResult(
      userId: userId,
      gameType: gameType,
      result: result,
      score: score,
      timeTakenSeconds: timeTakenSeconds,
      accuracyPercent: accuracyPercent,
    );

    // 3. Обновляем опыт и ранг в локальной таблице users
    final currentUser = await (_db.select(
      _db.usersTable,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (currentUser != null) {
      int newExp = currentUser.experience + score;
      int newRank = _calculateRank(newExp);
      await (_db.update(
        _db.usersTable,
      )..where((t) => t.id.equals(userId))).write(
        UsersTableCompanion(experience: Value(newExp), rank: Value(newRank)),
      );
    }
    // отправка на сервер, если возможно
    try {
      await _api.submitGameResult(
        userId: userId,
        gameType: gameType,
        result: result,
        score: score,
        timeTakenSeconds: timeTakenSeconds,
        accuracyPercent: accuracyPercent,
      );
    } catch (_) {}
  }

  int _calculateRank(int exp) {
    if (exp < 1000) return 0;
    if (exp < 3000) return 1;
    if (exp < 6000) return 2;
    if (exp < 10000) return 3;
    return 4;
  }

  /// Поток истории игр пользователя
  Stream<List<GameSession>> watchSessions(String userId) {
    final query = _db.select(_db.gameSessions)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.playedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  /// Таблица лидеров (с сервера)
  Future<List<UserRank>> getLeaderboard() async {
    try {
      final serverData = await _api.getLeaderboard();
      if (serverData.isNotEmpty) {
        return serverData.map((json) {
          final id = json['userId'] ?? json['userID'] ?? json['id'] ?? '';
          final email = json['email'] ?? json['Email'] ?? 'unknown';
          final exp =
              (json['experience'] ??
                      json['experiencePoints'] ??
                      json['xp'] ??
                      0)
                  as int;
          final rnk = (json['rank'] ?? json['playerRank'] ?? 0) as int;
          return UserRank(userId: id, email: email, experience: exp, rank: rnk);
        }).toList();
      }
    } catch (e) {
      print('Ошибка при обработке таблицы лидеров: $e');
    }
    return getLocalLeaderboard();
  }

  /// Ранг текущего пользователя (исправленная версия)
  Future<UserRank?> getUserRank(String serverUserId) async {
    final user = await (_db.select(
      _db.usersTable,
    )..where((t) => t.id.equals(serverUserId))).getSingleOrNull();
    if (user == null) return null;

    return UserRank(
      userId: user.id,
      email: user.email,
      experience: user.experience,
      rank: user.rank,
    );
  }

  /// Получить профиль бота с сервера
  Future<Map<String, dynamic>> getBotProfile(String userId) async {
    final profile = await _api.getBotProfile(userId);
    return {
      'averageSpeed': (profile['averageSpeed'] as num?)?.toDouble() ?? 4.0,
      'accuracy': (profile['accuracy'] as num?)?.toInt() ?? 80,
    };
  }

  Future<List<DeckWithCount>> getDecksForUser(String userId) async {
    return _db.watchDecksWithCardCount(userId).first;
  }

  /// Локальная таблица лидеров – все пользователи, упорядоченные по опыту
  Future<List<UserRank>> getLocalLeaderboard() async {
    final users =
        await (_db.select(_db.usersTable)
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.experience,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(20))
            .get();

    return users
        .map(
          (u) => UserRank(
            userId: u.id,
            email: u.email,
            experience: u.experience,
            rank: u.rank,
          ),
        )
        .toList();
  }
}
