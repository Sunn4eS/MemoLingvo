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

  AppDatabase get database => _db;

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

    try {
      bool sent = await _api.submitGameResult(
        userId: userId,
        gameType: gameType,
        result: result,
        score: score,
        timeTakenSeconds: timeTakenSeconds,
        accuracyPercent: accuracyPercent,
      );

      if (sent) {
        final leaderboard = await _api.getLeaderboard();
        Map<String, dynamic>? serverEntry;
        for (final entry in leaderboard) {
          final id = entry['userId'] ?? entry['userID'] ?? entry['id'] ?? '';
          if (id == userId) {
            serverEntry = entry;
            break;
          }
        }

        if (serverEntry != null) {
          final serverExp = (serverEntry['experience'] as num?)?.toInt() ?? 0;
          final serverRank = (serverEntry['rank'] as num?)?.toInt() ?? 0;
          await (_db.update(
            _db.usersTable,
          )..where((t) => t.id.equals(userId))).write(
            UsersTableCompanion(
              experience: Value(serverExp),
              rank: Value(serverRank),
            ),
          );
          print('✅ Опыт синхронизирован с сервером: $serverExp XP');
        } else {
          print(
            '⚠️ Не удалось найти себя в лидерборде, опыт может расходиться',
          );
        }
      } else {
        print('⚠️ Сервер не принял результат, опыт остался локальным');
      }
    } catch (e) {
      print('❌ Ошибка синхронизации с сервером: $e');
    }
  }

  int _calculateRank(int exp) {
    if (exp < 4000) return 0;
    if (exp < 8000) return 1;
    if (exp < 12000) return 2;
    if (exp < 16000) return 3;
    return 4;
  }

  Stream<List<GameSession>> watchSessions(String userId) {
    final query = _db.select(_db.gameSessions)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.playedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

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

  Future<List<DeckWithCount>> getDecksForUser(String userId) async {
    return _db.watchDecksWithCardCount(userId).first;
  }

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
