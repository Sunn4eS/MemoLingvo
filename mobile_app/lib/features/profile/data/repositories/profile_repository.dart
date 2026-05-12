import 'dart:io';
import 'package:drift/drift.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/profile/domain/entities/user_profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final AppDatabase _db;
  final SharedPreferences _prefs;

  ProfileRepository(this._db, this._prefs);

  Future<UserProfile?> getLocalProfile(String email) async {
    final userData = await (_db.select(
      _db.usersTable,
    )..where((t) => t.email.equals(email))).getSingleOrNull();
    if (userData == null) return null;
    return UserProfile(
      id: userData.id,
      email: userData.email,
      createdAt: userData.createdAt,
    );
  }

  Future<Map<String, int>> getLearningStats(String userId) async {
    final totalCardsQuery = _db.select(_db.cards).join([
      innerJoin(_db.decks, _db.decks.id.equalsExp(_db.cards.deckId)),
    ]);

    totalCardsQuery.where(_db.decks.userId.equals(userId));
    totalCardsQuery.where(_db.cards.isDeleted.equals(false));

    final totalCardsRows = await totalCardsQuery.get();
    final totalCards = totalCardsRows.length;

    final progressList = await (_db.select(
      _db.cardProgress,
    )..where((t) => t.userId.equals(userId))).get();

    final activeCardIds = totalCardsRows
        .map((r) => r.readTable(_db.cards).id)
        .toSet();
    final activeProgress = progressList
        .where((p) => activeCardIds.contains(p.cardId))
        .toList();

    int mastered = activeProgress.where((p) => p.repetitions >= 5).length;
    int learning = activeProgress
        .where((p) => p.repetitions > 0 && p.repetitions < 5)
        .length;
    int newCards = totalCards - (mastered + learning);

    return {
      'total': totalCards,
      'mastered': mastered,
      'learning': learning,
      'new': newCards,
    };
  }

  String? getAvatarPath() {
    return _prefs.getString('avatar_path');
  }

  Future<void> saveAvatarPath(String? path) async {
    if (path == null) {
      await _prefs.remove('avatar_path');
    } else {
      await _prefs.setString('avatar_path', path);
    }
  }

  Future<bool> updateAvatarFromFile(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final newPath = '${avatarsDir.path}/$fileName';
      await imageFile.copy(newPath);
      await saveAvatarPath(newPath);
      return true;
    } catch (e) {
      print('Ошибка сохранения аватара: $e');
      return false;
    }
  }

  Stream<List<({Card card, CardProgressData progress})>>
  watchLearnedCardsWithProgress(String userId) {
    final query =
        _db.select(_db.cards).join([
            innerJoin(
              _db.cardProgress,
              _db.cardProgress.cardId.equalsExp(_db.cards.id),
            ),
          ])
          ..where(
            _db.cardProgress.userId.equals(userId) &
                _db.cardProgress.repetitions.isBiggerOrEqualValue(5),
          )
          ..where(_db.cards.isDeleted.equals(false));
    return query.watch().map((rows) {
      return rows.map((row) {
        final card = row.readTable(_db.cards);
        final progress = row.readTable(_db.cardProgress);
        return (card: card, progress: progress);
      }).toList();
    });
  }
}
