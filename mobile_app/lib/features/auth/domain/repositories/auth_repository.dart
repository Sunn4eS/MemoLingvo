import 'package:lingo_cards/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signUpWithEmailAndPassword(String email, String password, String displayName);
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}