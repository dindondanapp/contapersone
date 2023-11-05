import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen with basic information on this app
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.infoScreenTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150),
                    child: Image.asset(
                      'assets/round_icon.png',
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.infoScreenText,
                  textAlign: TextAlign.justify,
                ),
                ...(kIsWeb
                    ? [
                        SizedBox(height: 40),
                        ElevatedButton(
                          child:
                              Text(AppLocalizations.of(context)!.donateButton),
                          onPressed: () => launchUrl(
                              Uri.parse('https://dindondan.app/donate.php')),
                        )
                      ]
                    : []),
                SizedBox(height: 40),
                TextButton.icon(
                  icon: Icon(Icons.mail),
                  label: Text('Feedback'),
                  onPressed: () =>
                      launchUrl(Uri.parse('mailto:feedback@dindondan.app')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
