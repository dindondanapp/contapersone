import 'package:contapersone/common/entities.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/scan_uri_qr_code.dart';

class CounterJoinForm extends StatelessWidget {
  final bool enabled;
  final void Function(CounterToken token) onSuccess;
  final void Function() onError;

  const CounterJoinForm(
      {Key key, @required this.enabled, @required this.onSuccess, this.onError})
      : super(key: key);

  @override
  build(BuildContext context) {
    return Column(
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
                'Chiedi al creatore del contapersone di inviarti il link, oppure scarica la versione mobile di Contapersone da App Store o Play Store per inquadrare il codice QR');
          } else {
            return RaisedButton.icon(
              onPressed: enabled ? () => _scan(context) : null,
              label: Text('Inquadra il codice QR'),
              icon: Icon(Icons.camera_alt),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
            );
          }
        }(),
      ],
    );
  }

  Future<void> _scan(BuildContext context) async {
    try {
      Uri uri = await scanUriQRCode(context);
      FirebaseAnalytics().logEvent(name: 'scan', parameters: null);

      PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getDynamicLink(uri);

      if (data.link.queryParameters.containsKey('token')) {
        onSuccess(CounterToken.fromString(data.link.queryParameters['token']));
      } else {
        if (onError != null) {
          onError();
        } else {
          throw Exception('Inval code scanned.');
        }
      }
    } catch (error) {
      FirebaseAnalytics().logEvent(name: 'scan_fail', parameters: null);
      if (onError != null) {
        onError();
      } else {
        throw Exception('Inval code scanned.');
      }
      // TODO: Provide visual feedback
    }
  }
}