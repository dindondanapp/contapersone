import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/auth.dart';
import '../common/secret.dart';

/// A screen for authenticating with Firebase Authentication
class SignInScreen extends StatefulWidget {
  final Auth auth;
  SignInScreen({this.auth});

  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).signInScreenTitle),
      ),
      body: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: AppLocalizations.of(context).signInEmailHint,
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? AppLocalizations.of(context).signInEmailValidator
            : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: AppLocalizations.of(context).signInPasswordHint,
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? AppLocalizations.of(context).signInPasswordValidator
            : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSigninButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            child: new Text(AppLocalizations.of(context).signInSubmit),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showSignupButton() {
    return new FlatButton(
        child: new Text(AppLocalizations.of(context).signUpButton,
            textAlign: TextAlign.center, style: new TextStyle(fontSize: 16.0)),
        onPressed: () => launch(Secret.signUpURL));
  }

  Widget _showPasswordRecovery() {
    return new FlatButton(
        child: new Text(AppLocalizations.of(context).forgotPasswordButton,
            style: new TextStyle(fontSize: 16.0)),
        onPressed: () => launch(Secret.recoverPasswordURL));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.red[800],
            height: 1.0,
            fontWeight: FontWeight.bold),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 350),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).signInReservedWarning,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  Text(''),
                  Text(
                    AppLocalizations.of(context).signInFormCaption,
                    textAlign: TextAlign.center,
                  ),
                  _showEmailInput(),
                  _showPasswordInput(),
                  SizedBox(
                    height: 20,
                  ),
                  _showErrorMessage(),
                  _showSigninButton(),
                  SizedBox(
                    height: 20,
                  ),
                  _showSignupButton(),
                  _showPasswordRecovery(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      FirebaseAnalytics().logEvent(name: 'signin_attempt', parameters: null);
      setState(() {
        _isLoading = false;
      });
      try {
        FirebaseAnalytics()
            .logEvent(name: 'signin_successful', parameters: null);
        // Firebase sign-in
        await widget.auth.signIn(_email, _password);
        print('Signed in.');
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (error) {
        print('Error: ${error.code}');
        String message = AppLocalizations.of(context).signInUnknownErrorMessage;

        switch (error.code) {
          case "invalid-email":
            message = AppLocalizations.of(context).signInInvalidEmailError;
            break;
          case "wrong-password":
            message = AppLocalizations.of(context).signInWrongPasswordError;
            break;
          case "user-not-found":
            message = AppLocalizations.of(context).signInUserNotFoundError;
            break;
          case "user-disabled":
            message = AppLocalizations.of(context).signInUserDisabledError;
            break;
          case "too-many-requests":
            message = AppLocalizations.of(context).signInTooManyAttemptsError;
            break;
          case "network-request-failed":
            message = AppLocalizations.of(context).signInNetworkError;
        }
        FirebaseAnalytics()
            .logEvent(name: 'signin_error', parameters: {'code': message});
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      } catch (error) {
        FirebaseAnalytics().logEvent(name: 'signin_error', parameters: null);
        print(error);
        print('Unexpected sign-in error.');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
