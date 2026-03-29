import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:memo_lingvo/features/profile/data/repositories/profile_repository.dart';
import 'package:memo_lingvo/features/profile/logic/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileCubit(this._profileRepository, this._authRepository)
    : super(ProfileInitial()) {
    loadProfile;
  }

  void loadProfile() {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(ProfileError("Пользователь не авторизован"));
      return;
    }

    _profileRepository
        .watchUserProfile(userId)
        .listen(
          (data) {
            print("🎯 Данные из Firestore пришли: $data"); // ДЛЯ ТЕСТА

            final xp = data['xp'] as int? ?? 0;

            emit(
              ProfileLoaded(
                nickname: data['nickname'] as String? ?? 'Изучающий Lingo',
                avatarUrl: data['avatarUrl'] as String?,
                xp: xp,
                rank: _calculateRank(xp),
              ),
            );
          },
          onError: (error) {
            // 🚨 ЕСЛИ ЕСТЬ ОШИБКА, ОНА ВЫВЕДЕТСЯ СЮДА:
            print("💥 ОШИБКА FIRESTORE В CUBIT: $error");
            emit(ProfileError("Ошибка загрузки профиля: $error"));
          },
        );
  }

  Future<void> updateAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  }

  String _calculateRank(int xp) {
    if (xp < 100) return "Новичок 🎓";
    if (xp < 500) return "Продвинутый 📚";
    return "Магистр Слов 🧙‍♂️";
  }
}
