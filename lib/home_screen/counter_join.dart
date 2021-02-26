import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/entities.dart';
import '../common/scan_uri_qr_code.dart';

/// A simple form to join a shared counter by scanning a QR code
class CounterJoinForm extends StatelessWidget {
  final bool enabled;
  final void Function(CounterToken token) onSuccess;
  final void Function() onError;

  /// Creates a simple form to join a shared counter by scanning a QR code.
  ///
  /// An `onSuccess` callback must be specified to handle successful counter
  /// token aquisition. The `onError` callback is called in case of any error
  /// during scanning or token acquisition. If `onError` is not provided, an
  /// Exception will be thrown instead.
  ///
  /// The argument `enabled` can be set to `false` to grey out the actions.
  const CounterJoinForm(
      {Key key, this.enabled = true, @required this.onSuccess, this.onError})
      : super(key: key);

  @override
  build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).scanQrCaption,
          textAlign: TextAlign.center,
        ),
        Container(
          height: 20,
        ),
        () {
          if (kIsWeb) {
            return Text(
              AppLocalizations.of(context).scanQrWebNotice,
            );
          } else {
            return RaisedButton.icon(
              onPressed: enabled ? () => _scan(context) : null,
              label: Text(AppLocalizations.of(context).scanQrButton),
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
