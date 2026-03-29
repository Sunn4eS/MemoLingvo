import 'package:firebase_auth/firebase_auth.dart';
//import 'package:memo_lingvo/features/auth/data/models/user_model.dart';

class AuthRepository {
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get userStatus => _firebaseAuth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async => await _firebaseAuth.signOut();
}
