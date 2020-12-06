import 'dart:async';

import 'package:flutter/material.dart';

Future<void> showErrorDialog(
    {@required BuildContext context,
    @required String title,
    String text,
    void onRetry(),
    void onExit(),
    void onContinue()}) {
  final actions = List<Widget>();

  final completer = Completer<void>();

  if (onRetry != null) {
    actions.add(
      FlatButton(
        child: Text('Riprova'),
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
      FlatButton(
        child: Text('Esci'),
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
      FlatButton(
        child: Text('Continua'),
        onPressed: () {
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
