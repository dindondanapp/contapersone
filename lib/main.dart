import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'common/palette.dart';
import 'home_screen/home_screen.dart';

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
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Palette.primary,
            brightness: Brightness.light,
          ).copyWith(primary: Palette.primary),
        ),
        darkTheme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Palette.primary,
            brightness: Brightness.dark,
          ).copyWith(primary: Palette.primary),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
        },
      ),
    );
  }
}
