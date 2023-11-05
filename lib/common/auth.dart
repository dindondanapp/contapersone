import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication controller based on Firebase Authentication
class Auth extends ValueNotifier<AuthValue> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getters and setters
  AuthStatus? get status => value.status;
  set status(AuthStatus? newValue) =>
      value = value.rebuildWith(status: newValue);

  String? get userId => value.userId;
  set userId(String? newValue) => value = value.rebuildWith(userId: newValue);

  String? get churchName => value.churchName;
  set churchName(String? newValue) =>
      value = value.rebuildWith(churchName: newValue);

  AuthError? get error => value.error;
  set error(AuthError? newValue) => value = value.rebuildWith(error: newValue);

  /// Create an authentication controller and retrieve the authentication status.
  /// If the user is not signed-in, sign in anonymously.
  Auth() : super(AuthValue(status: AuthStatus.undefined)) {
    refreshState();
  }

  FutureOr<void> refreshState() {
    if (_firebaseAuth.currentUser == null) {
      return signInAnonymously();
    } else {
      if (_firebaseAuth.currentUser!.isAnonymous) {
        this.status = AuthStatus.loggedInAnonymously;
      } else {
        this.status = AuthStatus.loggedIn;
      }
      this.userId = _firebaseAuth.currentUser!.uid;
    }
  }

  /// Sign in anonymously with Firebase Authentication
  FutureOr<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously().timeout(Duration(seconds: 10));
      this.status = AuthStatus.loggedInAnonymously;
      this.userId = getCurrentUser()?.uid;
    } catch (error) {
      this.status = AuthStatus.notLoggedIn;
      this.error = AuthError.anonymous;
      this.userId = null;
      throw error;
    }
  }

  /// Sign in with Firebase Authentication given email and password
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    refreshState();

    this.status = AuthStatus.loggedIn;
    this.userId = getCurrentUser()?.uid;
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Sign out
  void signOut() async {
    await _firebaseAuth.signOut();
    refreshState();
    this.status = AuthStatus.notLoggedIn;
    this.userId = null;
  }
}

/// An object that describes the authentication status
class AuthValue {
  final String? userId;
  final String? churchName;
  final AuthStatus? status;
  final AuthError? error;

  AuthValue({this.churchName, this.userId, required this.status, this.error});

  AuthValue rebuildWith(
      {String? churchName,
      String? userId,
      AuthStatus? status,
      AuthError? error}) {
    return AuthValue(
      churchName: churchName ?? this.churchName,
      status: status ?? this.status,
      error: error ?? this.error,
      userId: userId ?? this.userId,
    );
  }
}

enum AuthStatus {
  undefined,
  notLoggedIn,
  loggedIn,
  loggedInAnonymously,
}

enum AuthError { anonymous }
