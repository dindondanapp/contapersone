import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'common/extensions.dart';
import 'common/palette.dart';
import 'home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: MaterialApp(
        title: 'DinDonDan Contapersone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Palette.primary.toMaterialColor(),
          accentColor: Palette.primary.toMaterialColor(),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Home(),
        },
      ),
    );
  }
}
