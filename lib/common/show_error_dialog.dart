import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Display a simnplified error dialog and returns a [Future] that completes
/// when the dialog is dismissed
///
/// This function takes a `context` to identify the current [Navigator], a
/// `title` for the dialog, and optional `text` and three optional callbacks
/// for user actions on the dialog: `onRetry`, `onExit` and `onContinue`. If any
/// of the callbacks is [null], the correspondiong button will not be displayed.
///
/// Any action will also dismiss the dialog.
Future<void> showErrorDialog({
  @required BuildContext context,
  @required String title,
  String text,
  void onRetry(),
  void onExit(),
  void onContinue(),
}) {
  // Future Completer
  final completer = Completer<void>();

  final actions = <Widget>[];

  if (onRetry != null) {
    actions.add(
      TextButton(
        child: Text(AppLocalizations.of(context).tryAgain),
        onPressed: () {
          Navigator.of(context).pop();
          onRetry();
          completer.complete();
        },
      ),
    );
  }

  if (onExit != null) {
    actions.add(
      TextButton(
        child: Text(AppLocalizations.of(context).quit),
        onPressed: () {
          Navigator.of(context).pop();
          onExit();
          completer.complete();
        },
      ),
    );
  }

  if (onContinue != null) {
    actions.add(
      TextButton(
        child: Text(AppLocalizations.of(context).continueButton),
        onPressed: () {
          Navigator.of(context).pop();
          onContinue();
          completer.complete();
        },
      ),
    );
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: text != null
                ? ListBody(
                    children: <Widget>[
                      Text(text),
                    ],
                  )
                : null,
          ),
          actions: actions,
        ),
      );
    },
  );

  return completer.future;
}
