import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo_cards/features/auth/data/repositories/auth_repository.dart';
import 'package:lingo_cards/features/auth/domain/entities/user.dart';
import 'package:lingo_cards/features/auth/logic/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    _repository.userStatus.listen((user) {
      if (user != null) {
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
      // Состояние изменится автоматически через слушатель в _checkAuthStatus
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
