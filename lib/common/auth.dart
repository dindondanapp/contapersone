import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication controller based on Firebase Authentication
class Auth extends ValueNotifier<AuthValue> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Authentication status
  get status => value.status;
  set status(status) => value = AuthValue(status: status);

  /// Create an authentication controller and retrieve the authentication status.
  /// If the user is not signed-in, sign in anonymously.
  Auth() : super(AuthValue(status: AuthStatus.undefined)) {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      signInAnonymously();
    } else {
      if (_firebaseAuth.currentUser.isAnonymous) {
        this.value = AuthValue(status: AuthStatus.loggedInAnonymously);
      } else {
        this.value = AuthValue(status: AuthStatus.loggedIn);
      }
    }
  }

  /// Sign in anonymously with Firebase Authentication
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      this.value = AuthValue(status: AuthStatus.loggedInAnonymously);
    } catch (error) {
      this.value = AuthValue(status: AuthStatus.notLoggedIn);
    }
  }

  /// Sign in with Firebase Authentication given email and password
  Future<void> signIn(String email, String password) async {
    print('Signing in…');

    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    this.value = AuthValue(status: AuthStatus.loggedIn);
  }

  /// Get current user
  User getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Sign out
  void signOut() async {
    await _firebaseAuth.signOut();
    this.value = AuthValue(status: AuthStatus.notLoggedIn);
  }
}

/// An object that describes the authentication status
class AuthValue {
  final AuthStatus status;
  AuthValue({this.status});
}

enum AuthStatus {
  undefined,
  notLoggedIn,
  loggedIn,
  loggedInAnonymously,
}
