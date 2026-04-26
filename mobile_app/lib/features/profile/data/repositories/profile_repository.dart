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

  // Получить локальный профиль из БД (без аватара)
  Future<UserProfile?> getLocalProfile(String email) async {
    final userData = await (_db.select(_db.usersTable)
          ..where((t) => t.email.equals(email)))
        .getSingleOrNull();
    if (userData == null) return null;
    return UserProfile(
      id: userData.id,
      email: userData.email,
      createdAt: userData.createdAt,
      // аватар не храним в БД
    );
  }

  // Загрузить статистику прогресса
  Future<Map<String, int>> getLearningStats(String userId) async {
    final totalCards = await (_db.select(_db.cards)..where((t) => t.isDeleted.equals(false))).get().then((list) => list.length);
    final progressList = await (_db.select(_db.cardProgress)..where((t) => t.userId.equals(userId))).get();
    int mastered = progressList.where((p) => p.repetitions >= 5).length;
    int learning = progressList.where((p) => p.repetitions > 0 && p.repetitions < 5).length;
    int newCards = totalCards - (mastered + learning);
    return {
      'total': totalCards,
      'mastered': mastered,
      'learning': learning,
      'new': newCards,
    };
  }

  // Получить путь к аватару из SharedPreferences
  String? getAvatarPath() {
    return _prefs.getString('avatar_path');
  }

  // Сохранить путь к аватару (локально)
  Future<void> saveAvatarPath(String? path) async {
    if (path == null) {
      await _prefs.remove('avatar_path');
    } else {
      await _prefs.setString('avatar_path', path);
    }
  }

  // Обновить аватар: копируем выбранный файл в постоянное место (опционально) и сохраняем путь
  Future<bool> updateAvatarFromFile(File imageFile) async {
    try {
      // Создаём директорию для аватаров, если её нет
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }
      // Генерируем уникальное имя файла
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

  // Список выученных слов с джойном прогресса
  Stream<List<({Card card, CardProgressData progress})>> watchLearnedCardsWithProgress(String userId) {
    final query = _db.select(_db.cards).join([
      innerJoin(_db.cardProgress, _db.cardProgress.cardId.equalsExp(_db.cards.id)),
    ])
      ..where(_db.cardProgress.userId.equals(userId) & _db.cardProgress.repetitions.isBiggerOrEqualValue(5))
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