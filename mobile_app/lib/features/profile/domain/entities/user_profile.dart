import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? displayName;

  const UserProfile({
    required this.id,
    required this.email,
    required this.createdAt,
    this.avatarUrl,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, email, createdAt, avatarUrl, displayName];

  UserProfile copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    String? avatarUrl,
    String? displayName,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      displayName: displayName ?? this.displayName,
    );
  }
}
