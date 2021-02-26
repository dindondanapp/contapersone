import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/extensions.dart';
import '../counter_screen/counter_screen.dart';

class History extends StatefulWidget {
  final Auth auth;
  final void Function(CounterToken token) resumeCounter;

  const History({Key key, this.auth, @required this.resumeCounter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => HistoryState();
}

class HistoryState extends State<History> {
  Stream<List<CounterData>> _stream = Stream.empty();
  String _userId;

  @override
  void initState() {
    super.initState();

    widget.auth.addListener(() {
      if (widget.auth.userId != _userId) {
        _userId = widget.auth.userId;
        _updateStream();
      }
    });

    _updateStream();
  }

  _updateStream() {
    setState(() {
      if (widget.auth.userId == null) {
        _stream = Stream.empty();
      } else {
        _stream = FirebaseFirestore.instance
            .collection('counters')
            .where('deleted', isNull: true)
            .where('user_id', isEqualTo: widget.auth.userId)
            .orderBy('lastUpdated', descending: true)
            .limit(20)
            .snapshots()
            .distinct()
            .map<List<CounterData>>(
          (event) {
            return event.docs.map<CounterData>(
              (doc) {
                List<SubcounterData> subcounters = [];
                try {
                  if (doc.data()['subtotals'] != null) {
                    subcounters = (doc.data()['subtotals'] as Map)
                        .entries
                        .map<SubcounterData>(
                          (MapEntry e) => SubcounterData(
                            lastUpdated: e.value['lastUpdated'],
                            label: e.value['label'],
                            id: e.key,
                            count: e.value['count'],
                          ),
                        )
                        .toList();
                  }
                } catch (e) {}

                return CounterData(
                  CounterToken.fromString(doc.id),
                  lastUpdated: doc.data()['lastUpdated'],
                  total: doc.data()['total'],
                  capacity: doc.data()['capacity'],
                  subcounters: subcounters,
                );
              },
            ).toList();
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CounterData>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: [
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(AppLocalizations.of(context).historyTitle),
            SizedBox(height: 20),
            ...(snapshot.data.length > 0
                ? snapshot.data
                    .map(
                      (e) => _buildCounterTile(e),
                    )
                    .toList()
                : [
                    Text(
                      AppLocalizations.of(context).noHistoryNotice,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  ]),
          ]);
        } else {
          print(snapshot.error);
          return Column(
            children: [
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),
              Text(AppLocalizations.of(context).historyLoadingError),
              FlatButton.icon(
                icon: Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).tryAgain),
                onPressed: _updateStream,
              )
            ],
          );
        }
      },
      initialData: [],
    );
  }

  Widget _buildCounterTile(CounterData data) {
    final count = data.capacity != null
        ? '${data.total ?? 0} / ${data.capacity}'
        : (data.total ?? 0).toString();

    final time = data.lastUpdated == null
        ? ''
        : data.lastUpdated.toDate().toHumanString(context: context);

    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      builder: (context, _) {
        return ExpansionTile(
          title: Text(count, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(time),
          children: [
            ...(data.subcounters != null && data.subcounters.length > 1
                ? data.subcounters.map(
                    (e) => ListTile(
                      title: Text(e.count.toString()),
                      subtitle: e.label != null ? Text(e.label) : null,
                    ),
                  )
                : []),
            ButtonBar(
              buttonTextTheme: ButtonTextTheme.accent,
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context).delete),
                    ],
                  ),
                  onPressed: () => _deleteFromHistory(data.token),
                ),
                FlatButton(
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context).continueButton),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                  onPressed: () => widget.resumeCounter(data.token),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteFromHistory(CounterToken token) async {
    if (await _deleteConfirmDialog()) {
      FirebaseFirestore.instance
          .collection('counters')
          .doc(token.toString())
          .set(
        {
          'deleted': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<bool> _deleteConfirmDialog() {
    final completer = Completer<bool>();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).historyDeleteConfirmTitle),
          content:
              Text(AppLocalizations.of(context).historyDeleteConfirmMessage),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(true);
              },
              child: Text(
                AppLocalizations.of(context).confirm,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(false);
              },
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(color: Theme.of(context).primaryColor),
                // TODO: rely on Theme
              ),
            ),
          ],
        );
      },
    );

    return completer.future;
  }
}

class CounterData {
  final CounterToken token;
  final Timestamp lastUpdated;
  final int peak;
  final int total;
  final int capacity;
  final List<SubcounterData> subcounters;

  CounterData(
    this.token, {
    this.lastUpdated,
    this.peak,
    this.total,
    this.capacity,
    this.subcounters,
  });
}
