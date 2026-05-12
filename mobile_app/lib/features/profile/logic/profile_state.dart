import 'package:equatable/equatable.dart';
import 'package:memo_lingvo/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final Map<String, int> stats;
  final String? avatarPath;

  const ProfileLoaded(this.profile, this.stats, this.avatarPath);

  @override
  List<Object?> get props => [profile, stats, avatarPath];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
