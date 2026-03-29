import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<Map<String, dynamic>> watchUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.data() ?? {};
    });
  }

  Future<void> updateProfile(String userId, {String? nickname, int? xp}) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (xp != null) data['xp'] = xp;

    await _firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  Future<String> uploadAvatar(String userId, File file) async {
    final ref = _storage
        .ref()
        .child('users')
        .child('avatars')
        .child('$userId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
