import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'common/auth.dart';
import 'common/extensions.dart';
import 'common/palette.dart';
import 'home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final auth = Auth();
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: MaterialApp(
        title: 'DinDonDan Contapersone',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigator,
        theme: ThemeData(
          primaryColor: Palette.primary.toMaterialColor(),
          accentColor: Palette.primary.toMaterialColor(),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Home(
                auth: widget.auth,
              ),
        },
      ),
    );
  }
}
