import 'package:flutter/material.dart';

void showErrorDialog(
    {@required BuildContext context,
    @required String title,
    String text,
    void onRetry(),
    void onExit()}) {
  final actions = List<Widget>();

  if (onRetry != null) {
    actions.add(
      FlatButton(
        child: Text('Riprova'),
        onPressed: () {
          Navigator.of(context).pop();
          onRetry();
        },
      ),
    );
  }

  if (onExit != null) {
    FlatButton(
      child: Text('Esci'),
      onPressed: () {
        Navigator.of(context).pop();
        onExit();
      },
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
}
