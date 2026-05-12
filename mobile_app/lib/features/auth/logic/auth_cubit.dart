import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:memo_lingvo/features/auth/logic/auth_state.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final AppDatabase _db;

  AuthCubit(this._repository, this._db) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    _repository.userStatus.listen((user) async {
      if (user != null) {
        try {
          final email = user.email ?? 'no_email@test.com';
          final uid = user.uid;

          var localUser = await (_db.select(
            _db.usersTable,
          )..where((t) => t.email.equals(email))).getSingleOrNull();

          if (localUser == null) {
            final apiClient = ApiClient();

            var serverData = await apiClient.loginUser(email, uid);

            if (serverData == null) {
              serverData = await apiClient.registerUser(email, uid);
            }

            if (serverData != null) {
              final serverUserId =
                  serverData['userID'] ??
                  serverData['UserID'] ??
                  serverData['userId'];
              final createdAtStr =
                  serverData['createdAt'] ?? serverData['CreatedAt'];

              await _db
                  .into(_db.usersTable)
                  .insertOnConflictUpdate(
                    UsersTableCompanion.insert(
                      id: serverUserId,
                      email: email,
                      createdAt: createdAtStr != null
                          ? DateTime.parse(createdAtStr).toUtc()
                          : DateTime.now().toUtc(),
                    ),
                  );
              print("✅ Юзер успешно сохранен с ID: $serverUserId");

              final leaderboard = await apiClient.getLeaderboard();
              print("🔍 Лидерборд получен, записей: ${leaderboard.length}");

              Map<String, dynamic>? myData;
              for (final entry in leaderboard) {
                final entryUserId =
                    entry['userId'] ?? entry['userID'] ?? entry['id'] ?? '';
                if (entryUserId == serverUserId) {
                  myData = entry;
                  break;
                }
              }

              if (myData != null) {
                final exp = (myData!['experience'] as num?)?.toInt() ?? 0;
                final rank = (myData!['rank'] as num?)?.toInt() ?? 0;
                await (_db.update(
                  _db.usersTable,
                )..where((t) => t.id.equals(serverUserId))).write(
                  UsersTableCompanion(
                    experience: Value(exp),
                    rank: Value(rank),
                  ),
                );
                print("🎮 Опыт и ранг восстановлены: опыт=$exp, ранг=$rank");
              } else {
                print(
                  "⚠️ Пользователь $serverUserId не найден в таблице лидеров",
                );
              }
            } else {
              print("❌ Ошибка: Сервер не вернул данные юзера.");
            }
          }
        } catch (e) {
          print("❌ Ошибка сохранения юзера в локальную БД: $e");
        }

        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> register(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repository.signUp(email, password);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repository.signIn(email, password);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      emit(const AuthState.loading());
      await _repository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
