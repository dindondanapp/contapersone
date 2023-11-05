import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/common/show_error_dialog.dart';
import 'package:contapersone/home_screen/counter_join.dart';
import 'package:contapersone/signin_screen/signin_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_location_href/window_location_href.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/secret.dart';
import '../counter_screen/counter_screen.dart';
import '../info_screen/info_screen.dart';
import '../share_screen/share_screen.dart';
import 'counter_create.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = Auth();
  CounterToken _token = CounterToken();
  HomeStatus _status = HomeStatus.ready;
  final _capacityController = TextEditingController();
  String get _title => _auth.status == AuthStatus.loggedIn
      ? _auth.churchName ?? AppLocalizations.of(context)!.appBarLoginInProgress
      : AppLocalizations.of(context)!.appBarDefault;
  bool _modalOpen = false;
  bool get _buttonsEnabled =>
      _status == HomeStatus.ready &&
      (_auth.status == AuthStatus.loggedIn ||
          _auth.status == AuthStatus.loggedInAnonymously);

  @override
  void initState() {
    super.initState();

    _auth.addListener(() {
      if (!_modalOpen) {
        if (_auth.error == AuthError.apiGeneric) {
          _modalOpen = true;
          _showAccountError().then((value) => _modalOpen = false);
        } else if (_auth.error == AuthError.apiIncompleteSignup) {
          _modalOpen = true;
          _showIncompleteSignupError().then((value) => _modalOpen = false);
        } else if (_auth.error == AuthError.anonymous) {
          _showNetworkError().then((value) => _modalOpen = false);
        }
      }
    });

    if (kIsWeb) {
      // Retrieve the shared counter token from the query string, if present
      final webUri = Uri.tryParse(href ?? "");
      if (webUri != null && webUri.queryParameters['token'] != null) {
        print("Found web uri with token.");
        _followDeepLink(webUri);
      }
    } else {
      // Handle firebase dynamic links
      _initDynamicLinks().then((Uri? uri) {
        if (uri != null) {
          _followDeepLink(uri);
        }
      });

      FirebaseDynamicLinks.instance.onLink
          .listen((PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink.link;
        _followDeepLink(deepLink);
      });
    }
  }

  Future<Uri?> _initDynamicLinks() async {
    print("Checking for deep links.");
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data?.link == null) {
      return null;
    } else {
      return data!.link;
    }
  }

  void _followDeepLink(Uri uri) {
    if (uri.queryParameters.containsKey('token')) {
      _startSubcounter(
        token: CounterToken.fromString(uri.queryParameters['token']!),
      );
    }
  }

  void _startSubcounter({required CounterToken token, CounterData? initData}) {
    FirebaseAnalytics.instance
        .logEvent(name: 'start_subcounter', parameters: null);
    Navigator.of(context).popUntil((route) => route.isFirst);
    print('Starting subcounter for id $token');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CounterScreen(
          token: token,
          auth: _auth,
          initData: initData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ValueListenableBuilder<AuthValue>(
      valueListenable: _auth,
      builder: (context, authValue, _) {
        return Scaffold(
          appBar: _buildAppBar(authValue),
          bottomNavigationBar: _buildBottomNavigationBar(),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(30),
                constraints: BoxConstraints(maxWidth: 350),
                child: Column(children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CounterCreateForm(
                        capacityController: _capacityController,
                        onSubmit: _createCounter,
                        enabled: _buttonsEnabled,
                      ),
                    ),
                  ),
                  Container(height: 20),
                  Text(
                    AppLocalizations.of(context)!.orDivider,
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CounterJoinForm(
                        enabled: _buttonsEnabled,
                        onSuccess: (token) => _startSubcounter(token: token),
                        onError: () => {
                          //TODO: Handle
                        },
                      ),
                    ),
                  ),
                  History(
                    auth: _auth,
                    resumeCounter: (token, initData) =>
                        _startSubcounter(token: token, initData: initData),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(AuthValue auth) {
    return AppBar(
      title: Text(_title),
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
                    child: Text(AppLocalizations.of(context)!.parishSignOut),
                    value: 'signout',
                  ),
                ],
                onSelected: (value) => _signOut(),
              )
            ]
          : <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.parishSignIn),
                    value: 'signin',
                  ),
                ],
                onSelected: (value) => _openSignInScreen(),
              ),
            ],
    );
  }

  void _openSignInScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignInScreen(
          auth: _auth,
        ),
      ),
    );
  }

  void _openInfoScreen() {
    FirebaseAnalytics.instance.logEvent(name: 'open_info', parameters: null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InfoScreen(),
      ),
    );
  }

  void _signOut() {
    FirebaseAnalytics.instance.logEvent(name: 'signout', parameters: null);
    _auth.signOut();
  }

  void _createCounter() async {
    FirebaseAnalytics.instance
        .logEvent(name: 'create_counter', parameters: null);

    setState(() {
      _status = HomeStatus.creating_counter;
      print('Now creating counter.');
    });

    int? capacity;

    try {
      capacity = int.tryParse(_capacityController.text);
    } catch (e) {
      print('Invalid capacity provided');
      //TODO: Provide visual feedback
    }

    _token = CounterToken();

    try {
      final newCounterData = {
        'total': 0,
        'church_uuid': '',
        'creator': _auth.getCurrentUser()!.uid,
        'lastUpdated': Timestamp.now(),
        'capacity': capacity,
        'deleted': null
      };

      await FirebaseFirestore.instance
          .collection('counters')
          .doc(_token.toString())
          .set(newCounterData)
          .timeout(Duration(seconds: 10));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShareScreen(token: _token, auth: _auth),
        ),
      );

      setState(() {
        _status = HomeStatus.ready;
      });
    } catch (error) {
      FirebaseAnalytics.instance
          .logEvent(name: 'counter_creation_error', parameters: null);
      showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.createCounterErrorTitle,
        text: AppLocalizations.of(context)!.createCounterErrorMessage,
        onRetry: _createCounter,
      );
    }
  }

  Future<void> _showAccountError() {
    FirebaseAnalytics.instance
        .logEvent(name: 'account_error', parameters: null);

    return showErrorDialog(
      context: context,
      title: AppLocalizations.of(context)!.accountErrorTitle,
      text: AppLocalizations.of(context)!.accountErrorMessage,
      onRetry: _auth.refreshUserData,
      onExit: _auth.signOut,
    );
  }

  Future<void> _showNetworkError() {
    FirebaseAnalytics.instance
        .logEvent(name: 'connection_error', parameters: null);

    return showErrorDialog(
      context: context,
      title: AppLocalizations.of(context)!.networkErrorTitle,
      text: AppLocalizations.of(context)!.networkErrorMessage,
      onRetry: _auth.refreshState,
    );
  }

  Future<void> _showIncompleteSignupError() {
    FirebaseAnalytics.instance
        .logEvent(name: 'incomplete_signup_error', parameters: null);

    return showErrorDialog(
      context: context,
      title: AppLocalizations.of(context)!.incompleteSignUpErrorTitle,
      text: "",
      onContinue: () => launch(Secret.incompleteSignUpURL),
      onExit: () => _auth.signOut(),
    );
  }

  BottomAppBar? _buildBottomNavigationBar() {
    if (kIsWeb) {
      return BottomAppBar(
        child: Center(
          heightFactor: 1,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: MaterialButton(
              onPressed: () =>
                  launch('https://www.dindondan.app/contapersone/'),
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
                          'Stai usando l\'app in versione web. Se hai un dispositivo Android o iOS scarica la versione nativa!'),
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

  @override
  void dispose() {
    super.dispose();
    _capacityController.dispose();
    _auth.dispose();
  }
}

enum HomeStatus { ready, creating_counter, error }
