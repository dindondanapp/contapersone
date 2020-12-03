import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text('Accedi come parrocchia'),
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
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Inserisci l\'indirizzo e-mail' : null,
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
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Inserisci la password' : null,
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
            child: new Text('Accedi'),
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
        child: new Text('Non hai un account? Registrati ora!',
            style: new TextStyle(fontSize: 16.0)),
        onPressed: () => launch(Secret.signUpURL));
  }

  Widget _showPasswordRecovery() {
    return new FlatButton(
        child: new Text('Ho dimenticato la password',
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
                    'Attenzione! Il login è riservato alle parrocchie.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  Text(''),
                  Text(
                    'Per raccogliere statistiche sui conteggi per la tua parrocchia accedi con il tuo account DinDonDan:',
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
        String message =
            "Si è verificato un errore sconosciuto. Riprova più tardi e, se il problema persiste, scrivi a feedback@dindondan.app.";

        switch (error.code) {
          case "invalid-email":
            message =
                "L'indirizzo e-mail non è valido. Controlla che sia scritto correttamente e riprova.";
            break;
          case "wrong-password":
            message = "La password inserita è errata.";
            break;
          case "user-not-found":
            message = "Questo indirizzo non corrisponde ad alcun utente.";
            break;
          case "user-disabled":
            message =
                "Questo utente è stato disabilitato. Per ulteriori informazioni scrivi a feedback@dindondan.app.";
            break;
          case "too-many-requests":
            message = "Hai effettuato troppi tentativi. Riprova più tardi.";
            break;
          case "network-request-failed":
            message =
                "Impossibile connettersi al server. Verifica la connessione di rete e riprova.";
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
