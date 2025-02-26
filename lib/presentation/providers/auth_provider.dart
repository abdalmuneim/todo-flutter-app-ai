import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as app;

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app.User? _user;
  bool _isLoading = false;
  String? _error;

  app.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user in Firebase Auth
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then(
        (value) async {
          // Ensure the user is not null
          if (value.user == null) {
            throw Exception('User creation failed: User is null');
          }

          // Update display name in Firebase Auth
          await value.user?.updateDisplayName(displayName).catchError(
                (err) => log("Error updating display name: $err"),
              );

          // Create our app user
          final user = app.User(
            id: value.user!.uid,
            email: email,
            displayName: displayName,
            language: 'en',
          );

          // Save user data to Firestore
          await _firestore
              .collection('users')
              .doc(user.id)
              .set(user.toJson(), SetOptions(merge: true))
              .catchError(
                (err) => log("Error saving user data: $err"),
              );

          // Set current user
          _user = user;

          return value;
        },
      ).catchError(
        (err) {
          log("Error creating user: $err");
          throw err;
        },
      );
      return true;
    } catch (e) {
      _error = e.toString();
      print('Sign up error: $_error');
      rethrow;
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

      final userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .catchError((error) => throw error);

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .catchError((error) => throw error);

      if (userDoc.exists) {
        _user = app.User.fromJson(userDoc.data()!);
      } else {
        // If user document doesn't exist, create it
        final user = app.User(
          id: userCredential.user!.uid,
          email: email,
          displayName: userCredential.user?.displayName ?? email.split('@')[0],
          language: 'en',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.id)
            .set(user.toJson(), SetOptions(merge: true))
            .catchError((error) => throw error);

        _user = user;
      }
    } catch (e) {
      _error = e.toString();
      print('Sign in error: $_error');
      rethrow;
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

      if (_user == null) throw Exception('No user logged in');

      // Update Firebase Auth display name if provided
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }

      // Update Firestore user data
      final updatedUser = _user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        language: language,
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .set(updatedUser.toJson(), SetOptions(merge: true));

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
