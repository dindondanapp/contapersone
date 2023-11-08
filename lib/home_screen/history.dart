import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/extensions.dart';
import '../stats_screen/stats_screen.dart';

class History extends StatefulWidget {
  final Auth? auth;
  final void Function(CounterToken token, CounterData initData) resumeCounter;

  const History({Key? key, this.auth, required this.resumeCounter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => HistoryState();
}

class HistoryState extends State<History> {
  BehaviorSubject<List<CounterData>> _stream = BehaviorSubject();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    _currentUserId = widget.auth?.userId;
    widget.auth?.addListener(() {
      if (widget.auth?.userId != _currentUserId) {
        _currentUserId = widget.auth?.userId;
        _updateStream();
      }
    });

    _updateStream();
  }

  _updateStream() {
    setState(() {
      if (widget.auth?.userId == null) {
        _stream.add([]);
      } else {
        const limit = 20;

        final stream = FirebaseFirestore.instance
            .collection('counters')
            .where('users', arrayContains: widget.auth?.userId)
            .orderBy('lastUpdated', descending: true)
            .limit(limit)
            .snapshots()
            .distinct();

        final legacy = FirebaseFirestore.instance
            .collection('counters')
            .where('deleted', isNull: true)
            .where('user_id', isEqualTo: widget.auth?.userId)
            .orderBy('lastUpdated', descending: true)
            .limit(limit)
            .snapshots()
            .distinct();

        Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>,
            QuerySnapshot<Map<String, dynamic>>, List<CounterData>>(
          stream,
          legacy,
          (a, b) {
            // Obtain joint list of CounterData
            final list = [...a.docs, ...b.docs]
                .map<CounterData>(
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
                      creator: doc.data()['creator'],
                      subcounters: subcounters,
                    );
                  },
                )
                .toSet()
                .toList()
              ..sort((a, b) =>
                  (b.lastUpdated?.millisecondsSinceEpoch ?? 0) -
                  (a.lastUpdated?.millisecondsSinceEpoch ?? 0));

            return list.sublist(0, min(list.length, limit));
          },
        ).listen(_stream.add);
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
            Text(AppLocalizations.of(context)!.historyTitle),
            SizedBox(height: 20),
            ...(snapshot.data!.length > 0
                ? snapshot.data!
                    .map(
                      (e) => _buildCounterTile(e),
                    )
                    .toList()
                : [
                    Text(
                      AppLocalizations.of(context)!.noHistoryNotice,
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
              Text(AppLocalizations.of(context)!.historyLoadingError),
              TextButton.icon(
                icon: Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.tryAgain),
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
    final subtitle = data.subcounters.length == 1 &&
            data.subcounters.first.label != null &&
            data.subcounters.first.label != ''
        ? '${data.subcounters.first.label}'
        : '';

    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      initialData: 0,
      builder: (context, snapshot) {
        final userIsCreator = data.creator == widget.auth?.userId;
        return Card(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCounterTotal(
                      total: data.total,
                      capacity: data.capacity,
                      lastUpdated: data.lastUpdated,
                      subtitle: subtitle,
                    ),
                    IconTheme(
                      data:
                          IconThemeData(color: Theme.of(context).primaryColor),
                      child: ButtonBar(
                        buttonTextTheme: ButtonTextTheme.accent,
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteFromHistory(data.token),
                              ),
                              IconButton(
                                icon: Icon(Icons.show_chart),
                                onPressed: () => _openStatsScreen(data.token),
                              ),
                            ],
                          ),
                          TextButton(
                            child: Row(
                              children: [
                                Text(AppLocalizations.of(context)!
                                    .continueButton),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                            onPressed: () =>
                                widget.resumeCounter(data.token, data),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                !userIsCreator
                    ? Positioned(
                        child: Icon(Icons.people, color: Colors.grey[300]),
                        top: 20,
                        right: 20,
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterTotal({
    required int total,
    required int? capacity,
    required Timestamp? lastUpdated,
    String subtitle = '',
  }) {
    final timeString = lastUpdated == null
        ? ''
        : lastUpdated.toDate().asStrictlyPast().toHumanString(context: context);
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: total.toString(),
              children: [
                TextSpan(
                  text: capacity != null ? '/$capacity' : '',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
              style: TextStyle(fontSize: 25, color: Colors.black),
            ),
            textAlign: TextAlign.center,
          ),
          subtitle != ''
              ? Container(
                  child: Text(subtitle),
                  padding: EdgeInsets.only(bottom: 10),
                )
              : Container(),
          timeString != ''
              ? Text(
                  timeString,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void _openStatsScreen(CounterToken token) {
    FirebaseAnalytics.instance
        .logEvent(name: 'open_stats_from_history', parameters: null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatsScreen(
          token: token,
          auth: widget.auth!,
        ),
      ),
    );
  }

  void _deleteFromHistory(CounterToken token) async {
    if (await _deleteConfirmDialog()) {
      await FirebaseFirestore.instance
          .collection('counters')
          .doc(token.toString())
          .update({
        'deleted': Timestamp.now(), // For legacy
        'users': FieldValue.arrayRemove([widget.auth?.userId])
      });
    }
  }

  Future<bool> _deleteConfirmDialog() {
    final completer = Completer<bool>();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.historyDeleteConfirmTitle),
          content:
              Text(AppLocalizations.of(context)!.historyDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(true);
              },
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(false);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}
