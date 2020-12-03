import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/signin_screen/signin_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_location_href/window_location_href.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/scan_uri_qr_code.dart';
import '../common/secret.dart';
import '../counter_screen/counter_screen.dart';
import '../info_screen/info_screen.dart';
import '../share_screen/share_screen.dart';
import 'counter_create.dart';

class Home extends StatefulWidget {
  final Auth auth;

  Home({this.auth});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeStatus _status = HomeStatus.loaded;
  CounterToken _token = CounterToken();
  final _capacityController = TextEditingController();
  String _title;

  @override
  void initState() {
    super.initState();

    // Load user data and handle authentication status changes
    _refreshUserData();
    widget.auth.addListener(() {
      if (widget.auth.status == AuthStatus.loggedIn ||
          widget.auth.status == AuthStatus.loggedInAnonymously) {
        _refreshUserData();
      }
    });

    if (kIsWeb) {
      // Retrieve the shared counter token from the query string, if present
      final webUri = Uri.tryParse(getHref());
      if (webUri != null && webUri.queryParameters['token'] != null) {
        print("Found web uri with token.");
        _followDeepLink(webUri);
      }
    } else {
      // Handle firebase dynamic links
      _initDynamicLinks().then((Uri uri) {
        if (uri != null) {
          _followDeepLink(uri);
        }
      });

      FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            _followDeepLink(deepLink);
          }

          return null;
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);

          return null;
        },
      );
    }
  }

  Future<Uri> _initDynamicLinks() async {
    print("Checking for deep links.");
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink == null) {
      return null;
    } else {
      return deepLink;
    }
  }

  void _followDeepLink(Uri uri) {
    if (uri.queryParameters['token'] != null) {
      print('Starting subcounter from deep link.');
      _startSubcounter(
        token: CounterToken.fromString(uri.queryParameters['token']),
      );
    }
  }

  void _startSubcounter({@required CounterToken token}) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    print('Starting subcounter for id $token');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CounterScreen(token),
      ),
    );
  }

  /// Open the scanner screen, acquire and follow a deep link QR code
  void scan() async {
    try {
      Uri uri = await scanUriQRCode(context);
      PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getDynamicLink(uri);
      _followDeepLink(data.link);
    } catch (error) {
      print('Invalid code scanned.');
      // TODO: Provide visual feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    return new ValueListenableBuilder<AuthValue>(
      valueListenable: widget.auth,
      builder: (context, auth, _) {
        return Scaffold(
          appBar: _buildAppBar(auth),
          bottomNavigationBar: _buildBottomNavigationBar(),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(30),
                constraints: BoxConstraints(maxWidth: 350),
                child: Column(
                  children: () {
                    if (_status == HomeStatus.loading) {
                      return [_buildLoadingIndicator()];
                    } else if (_status == HomeStatus.loaded ||
                        _status == HomeStatus.creating_counter) {
                      return [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CounterCreate(
                              capacityController: _capacityController,
                              onSubmit: _createCounter,
                              enabled: _status == HomeStatus.loaded,
                            ),
                          ),
                        ),
                        Container(height: 20),
                        Text(
                          '– oppure –',
                          textAlign: TextAlign.center,
                        ),
                        Container(height: 20),
                        _buildScanQRCard(),
                      ];
                    } else {
                      return [Text('Errore sconosciuto')];
                    }
                  }(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AuthValue auth) {
    return AppBar(
      title: auth.status == AuthStatus.loggedIn
          ? Text(_title ?? '')
          : Text('Contapersone'),
      leading: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: _openInfoScreen,
      ),
      actions: auth.status == AuthStatus.loggedIn
          ? <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text('Disconnetti'),
                    value: 'signout',
                  ),
                ],
                onSelected: (value) => widget.auth.signOut(),
              )
            ]
          : <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text('Area riservata parrocchie'),
                    value: 'signin',
                  ),
                ],
                onSelected: (value) => _openSignInScreen(),
              )
            ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      ),
    );
  }

  void _openSignInScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignInScreen(
          auth: widget.auth,
        ),
      ),
    );
  }

  void _openInfoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InfoScreen(),
      ),
    );
  }

  Widget _buildScanQRCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Partecipa ad un contapersone condiviso esistente',
              textAlign: TextAlign.center,
            ),
            Container(
              height: 20,
            ),
            () {
              if (kIsWeb) {
                return Text(
                    'Chiedi al creatore del contapersone di inviarti il link, oppure scarica la versione mobile di DinDonDan contapersone per inquadrare il codice QR');
              } else {
                return RaisedButton.icon(
                  onPressed: _status == HomeStatus.loaded ? scan : null,
                  label: Text('Inquadra il codice QR'),
                  icon: Icon(Icons.camera_alt),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                );
              }
            }(),
          ],
        ),
      ),
    );
  }

  void _createCounter() {
    setState(() {
      _status = HomeStatus.creating_counter;
    });

    int capacity;

    try {
      capacity = int.parse(_capacityController.text);
    } catch (e) {
      print('Invalid capacity provided');
      //TODO: Provide visual feedback
    }

    _token = CounterToken();

    print("Creating counter for token $_token and capacity $capacity…");
    FirebaseFirestore.instance
        .collection('counters')
        .doc(_token.toString())
        .set({
      'total': 0,
      'church_uuid': '',
      'user_id': widget.auth.getCurrentUser().uid,
      'capacity': capacity
    }).then((value) {
      print("Navigating to share screen…");
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShareScreen(_token),
        ),
      );
    }).then((r) {
      setState(() {
        _status = HomeStatus.loaded;
      });
    }).catchError((e) {
      print('Authentication error');
      print(e);
      setState(() {
        _status = HomeStatus.error;
      });
    });
  }

  void _refreshUserData() async {
    if (widget.auth.status == AuthStatus.loggedIn) {
      setState(() {
        _title = 'Accesso in corso…';
      });
      try {
        //Fetch data
        String url = '${Secret.baseAPIURL}?key=${Secret.secretAPIKey}';
        Map<String, String> headers = {
          "Content-type": "application/x-www-form-urlencoded"
        };
        var user = widget.auth.getCurrentUser();
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

        setState(() {
          print('User data refreshed!');
          _title = result["church_name"].toString();
          _capacityController.text = result["capacity"].toString();
          _status = HomeStatus.loaded;
        });
      } catch (e) {
        print('User data fetch error.');
        print(e);
        if (e == 'INCOMPLETE_SIGNUP') {
          _showIncompleteSignupError();
        } else {
          _showConnectionError();
        }
        return;
      }
    } else {
      setState(() {
        print('Anonymous user data refreshed!');
        _title = null;
        _status = HomeStatus.loaded;
      });
    }
  }

  void _showConnectionError() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text('Errore di connessione'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Verifica che il dispositivo sia connesso.'),
                  Text(
                      'Se il problema persiste tocca "esci" e prova a ripetere l\'accesso.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Riprova'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _refreshUserData();
                },
              ),
              FlatButton(
                child: Text('Esci'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.auth.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIncompleteSignupError() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text('Errore di connessione'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Sembra che tu non abbia completato la registrazione.'),
                  Text(
                      'Per accedere devi fornire ancora alcuni dati. Tocca "continua" per concludere accedere ai servizi web e completare la registrazione.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Riprova'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _refreshUserData();
                },
              ),
              FlatButton(
                child: Text('Continua'),
                onPressed: () => launch(Secret.incompleteSignUpURL),
              ),
            ],
          ),
        );
      },
    );
  }

  BottomAppBar _buildBottomNavigationBar() {
    if (kIsWeb) {
      return BottomAppBar(
        child: Center(
          heightFactor: 1,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: MaterialButton(
              onPressed: () => launch(
                  'https://play.google.com/store/apps/details?id=app.dindondan.contapersone'),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      height: 60,
                      child: Image.asset('assets/icon_square.png'),
                    ),
                    Expanded(
                      child: Text(
                          'Stai usando l\'app in versione web. Se hai un dispositivo Android scarica la versione nativa dal Play Store!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return null;
    }
  }
}

enum HomeStatus { loading, loaded, creating_counter, error }
