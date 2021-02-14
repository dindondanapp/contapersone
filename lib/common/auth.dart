import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'secret.dart';

/// Authentication controller based on Firebase Authentication
class Auth extends ValueNotifier<AuthValue> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getters and setters
  get status => value.status;
  set status(AuthStatus newValue) =>
      value = value.rebuildWith(status: newValue);

  get userId => value.userId;
  set userId(String newValue) => value = value.rebuildWith(userId: newValue);

  get churchName => value.churchName;
  set churchName(String newValue) =>
      value = value.rebuildWith(churchName: newValue);

  get error => value.error;
  set error(AuthError newValue) => value = value.rebuildWith(error: newValue);

  /// Create an authentication controller and retrieve the authentication status.
  /// If the user is not signed-in, sign in anonymously.
  Auth() : super(AuthValue(status: AuthStatus.undefined)) {
    refreshState();
  }

  FutureOr<void> refreshState() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return signInAnonymously();
    } else {
      if (_firebaseAuth.currentUser.isAnonymous) {
        this.status = AuthStatus.loggedInAnonymously;
      } else {
        this.status = AuthStatus.loggedIn;
      }
      this.userId = user.uid;
    }

    refreshUserData();
  }

  /// Sign in anonymously with Firebase Authentication
  FutureOr<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously().timeout(Duration(seconds: 10));
      this.status = AuthStatus.loggedInAnonymously;
      this.userId = getCurrentUser().uid;
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
    this.userId = getCurrentUser().uid;
  }

  /// Get current user
  User getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Sign out
  void signOut() async {
    await _firebaseAuth.signOut();
    refreshState();
    this.status = AuthStatus.notLoggedIn;
    this.userId = null;
  }

  /// Load user data from custom API
  FutureOr<void> refreshUserData() async {
    try {
      if (status == AuthStatus.loggedIn) {
        //Fetch data
        String url = '${Secret.baseAPIURL}?key=${Secret.secretAPIKey}';
        Map<String, String> headers = {
          "Content-type": "application/x-www-form-urlencoded"
        };
        var user = getCurrentUser();
        var token = await user.getIdToken();
        String body = 'idToken=$token';

        Response response = await post(url, headers: headers, body: body);

        if (response.statusCode != 200) {
          throw 'REQUEST_ERROR_${response.statusCode}';
        }

        // Parse
        Map<String, dynamic> result = jsonDecode(response.body);
        if (result["error"] != null ||
            result["church_name"] == null ||
            result["capacity"] == null) {
          throw result["error"];
        }

        this.churchName = result["church_name"];
      } else {
        this.churchName = null;
      }

      this.error = null;
    } catch (error) {
      if (error == 'INCOMPLETE_SIGNUP') {
        this.error = AuthError.apiIncompleteSignup;
      }

      this.error = AuthError.apiGeneric;
      this.churchName = null;
      print(error);
    }
  }
}

/// An object that describes the authentication status
class AuthValue {
  final String userId;
  final String churchName;
  final AuthStatus status;
  final AuthError error;

  AuthValue({this.churchName, this.userId, @required this.status, this.error});

  AuthValue rebuildWith(
      {String churchName, String userId, AuthStatus status, AuthError error}) {
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

enum AuthError { apiIncompleteSignup, apiGeneric, anonymous }
