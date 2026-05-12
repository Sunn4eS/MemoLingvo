import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/profile/data/repositories/profile_repository.dart';
import 'package:memo_lingvo/features/profile/logic/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  final FirebaseAuth _auth;

  ProfileCubit(this._repository, this._auth) : super(ProfileInitial()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        emit(ProfileError('Пользователь не авторизован'));
        return;
      }

      final profile = await _repository.getLocalProfile(user.email!);
      if (profile == null) {
        emit(ProfileError('Профиль не найден'));
        return;
      }

      final stats = await _repository.getLearningStats(profile.id);
      final avatarPath = _repository.getAvatarPath();

      emit(ProfileLoaded(profile, stats, avatarPath));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateAvatar(File imageFile) async {
    final state = this.state;
    if (state is! ProfileLoaded) return;

    final success = await _repository.updateAvatarFromFile(imageFile);
    if (success) {
      await loadProfile();
    } else {
      emit(ProfileError('Не удалось сохранить аватар'));
    }
  }

  Future<void> removeAvatar() async {
    final state = this.state;
    if (state is! ProfileLoaded) return;

    await _repository.saveAvatarPath(null);
    await loadProfile();
  }
}
