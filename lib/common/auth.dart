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

  get churchName => value.churchName;
  set churchName(String newValue) =>
      value = value.rebuildWith(churchName: newValue);

  get apiError => value.apiError;
  set apiError(ApiError newValue) =>
      value = value.rebuildWith(apiError: newValue);

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
    }

    refreshUserData();
  }

  /// Sign in anonymously with Firebase Authentication
  FutureOr<void> signInAnonymously() async {
    try {
      print('loggininAnonym');
      await _firebaseAuth.signInAnonymously().timeout(Duration(seconds: 10));
      this.status = AuthStatus.loggedInAnonymously;
      print('loggedInAnonym');
    } catch (error) {
      print('anonymLoginError');
      this.status = AuthStatus.notLoggedIn;
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

      this.apiError = null;
    } catch (error) {
      if (error == 'INCOMPLETE_SIGNUP') {
        this.apiError = ApiError.incompleteSignup;
      }

      this.apiError = ApiError.other;
      this.churchName = null;
      print(error);
    }
  }
}

/// An object that describes the authentication status
class AuthValue {
  final AuthStatus status;
  final String churchName;
  final ApiError apiError;

  AuthValue({this.churchName, @required this.status, this.apiError});

  AuthValue rebuildWith(
      {String churchName, AuthStatus status, ApiError apiError}) {
    return AuthValue(
      churchName: churchName ?? this.churchName,
      status: status ?? this.status,
      apiError: apiError ?? this.apiError,
    );
  }
}

enum AuthStatus {
  undefined,
  notLoggedIn,
  loggedIn,
  loggedInAnonymously,
}

enum ApiError { incompleteSignup, other }
