
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> register(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(
      userModel.toMap(),
    );

    return userModel;
  }

  Future<UserCredential> login(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }
}
