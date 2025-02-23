import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as app;

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app.User? _user;
  firebase_auth.User? currentUser;
  bool _isLoading = false;
  String? _error;

  app.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser = userCredential.user;
      final user = app.User(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        language: 'en',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
      _user = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = userCredential.user;
      final userData = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      _user = app.User.fromJson(userData.data()!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? language,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) return;

      final updatedUser = _user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        language: language,
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toJson());

      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthState() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();

        _user = app.User.fromJson(userData.data()!);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }
}
