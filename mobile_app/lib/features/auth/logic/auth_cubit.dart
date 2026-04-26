import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:memo_lingvo/features/auth/logic/auth_state.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
//import 'package:memo_lingvo/core/utils.dart';
import 'package:memo_lingvo/core/network/api_client.dart'; 

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final AppDatabase _db;

  AuthCubit(this._repository, this._db) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  // В файле: lib/features/auth/logic/auth_cubit.dart
// Не забудь добавить импорт

  // В файле: lib/features/auth/logic/auth_cubit.dart

  void _checkAuthStatus() {
    _repository.userStatus.listen((user) async {
      if (user != null) {
        try {
          final email = user.email ?? 'no_email@test.com';
          final uid = user.uid; // Берем UID
          
          var localUser = await (_db.select(_db.usersTable)..where((t) => t.email.equals(email))).getSingleOrNull();

          if (localUser == null) {
            final apiClient = ApiClient();
            
            // 1. Пробуем войти, используя UID как пароль
            var serverData = await apiClient.loginUser(email, uid);
            
            // 2. Если не вышло, регистрируемся
            if (serverData == null) {
               serverData = await apiClient.registerUser(email, uid);
            }

            if (serverData != null) {
              final serverUserId = serverData['userID'] ?? serverData['UserID'] ?? serverData['userId'];
              final createdAtStr = serverData['createdAt'] ?? serverData['CreatedAt'];

              // ЖДЕМ завершения записи в БД!
              await _db.into(_db.usersTable).insertOnConflictUpdate(
                UsersTableCompanion.insert(
                  id: serverUserId, 
                  email: email,
                  createdAt: createdAtStr != null 
                      ? DateTime.parse(createdAtStr).toUtc() 
                      : DateTime.now().toUtc(),
                ),
              );
              print("✅ Юзер успешно сохранен с ID: $serverUserId");
            } else {
              print("❌ Ошибка: Сервер не вернул данные юзера.");
            }
          }
        } catch (e) {
          print("❌ Ошибка сохранения юзера в локальную БД: $e");
        }

        // Пускаем в приложение ТОЛЬКО после того, как разобрались с БД
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
      // Нам не нужно делать тут emit или сохранять в БД. 
      // _checkAuthStatus поймает это событие сам!
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