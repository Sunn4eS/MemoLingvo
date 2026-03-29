abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String nickname;
  final String? avatarUrl;
  final String rank;
  final int xp;
  ProfileLoaded({
    required this.nickname,
    this.avatarUrl,
    required this.rank,
    required this.xp,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
