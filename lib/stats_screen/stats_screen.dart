import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/common/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/extensions.dart';

class StatsScreen extends StatefulWidget {
  final Auth auth;
  final CounterToken token;

  const StatsScreen({
    Key key,
    this.auth,
    this.token,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  String _userId;
  Stream<CounterData> _counterDataStream = Stream.empty();
  Stream<CounterPeak> _peakStream = Stream.empty();

  @override
  void initState() {
    super.initState();

    widget.auth.addListener(() {
      if (widget.auth.userId != _userId) {
        _userId = widget.auth.userId;
        _updateStreams();
      }
    });

    _updateStreams();
  }

  _updateStreams() {
    setState(() {
      if (widget.auth.userId == null) {
        _counterDataStream = Stream.empty();
        _peakStream = Stream.empty();
      } else {
        _counterDataStream = FirebaseFirestore.instance
            .collection('counters')
            .doc(widget.token.toString())
            .snapshots()
            .map(
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
        );

        final subcountersStream = FirebaseFirestore.instance
            .collection('counters')
            .doc(widget.token.toString())
            .collection('subcounters')
            .limit(20)
            .snapshots();

        _peakStream = subcountersStream.map((event) {
          final List<dynamic> addEvents = [];
          final List<dynamic> subtractEvents = [];
          event.docs.forEach((doc) {
            addEvents.addAll(doc.data()['add_events'] as List<dynamic> ?? []);
            subtractEvents
                .addAll(doc.data()['subtract_events'] as List<dynamic> ?? []);
          });

          //TODO: check add and subtract events type
          Map<Timestamp, int> variations = Map.fromEntries([
            ...addEvents
                .map((time) => MapEntry<Timestamp, int>(time as Timestamp, 1)),
            ...subtractEvents
                .map((time) => MapEntry<Timestamp, int>(time as Timestamp, -1)),
          ]);
          final sortedVariations = (variations.entries.toList()
            ..sort((a, b) =>
                a.key.toDate().difference(b.key.toDate()).inMilliseconds));

          int peakValue = 0;
          DateTime peakTime;
          var trailing = 0;

          for (final variation in sortedVariations) {
            trailing += variation.value;
            if (trailing > peakValue) {
              peakValue = trailing;
              peakTime = variation.key.toDate();
            }
          }

          return CounterPeak(peakValue, peakTime);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).statsScreenTitle),
        backgroundColor: Palette.primary,
      ),
      body: _buildCounterStateWidget(),
    );
  }

  Widget _buildCounterStateWidget() {
    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      initialData: 0,
      builder: (context, snapshot) => StreamBuilder<CounterData>(
        stream: _counterDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          final data = snapshot.data;

          final subtitle = data.subcounters.length == 1 &&
                  data.subcounters.first.label != null &&
                  data.subcounters.first.label != ''
              ? '${data.subcounters.first.label}'
              : '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: data.total.toString(),
                        children: [
                          TextSpan(
                            text: data.capacity != null
                                ? '/${data.capacity}'
                                : '',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
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
                  ],
                ),
              ),
              ..._buildStatTiles(data),
            ],
          );
        },
      ),
    );
  }

  Iterable<Widget> _buildStatTiles(CounterData data) sync* {
    final timeString = data.lastUpdated == null
        ? ''
        : data.lastUpdated
            .toDate()
            .asStrictlyPast()
            .toHumanString(context: context);
    yield ListTile(
      title: Text(AppLocalizations.of(context).lastUpdate),
      subtitle: Text(timeString),
    );
    yield ListTile(
      title: Text(AppLocalizations.of(context).peakValue),
      subtitle: StreamBuilder<CounterPeak>(
          stream: _peakStream,
          initialData: CounterPeak(0, DateTime.now()),
          builder: (context, snapshot) {
            final value = snapshot.data.value;
            final timeString = snapshot.data.time != null
                ? ' (${snapshot.data.time.asStrictlyPast().toHumanString(context: context, maximumDuration: Duration.zero)})'
                : '';
            return Text('$value$timeString');
          }),
    );
    if (data.subcounters != null && data.subcounters.length > 1) {
      yield Divider();
      yield ListTile(
        title: Text(
          AppLocalizations.of(context).entrances,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
      );
      yield* data.subcounters.map(
        (e) => ListTile(
          title: Text(e.count.toString()),
          subtitle: e.label != null && e.label.trim() != ''
              ? Text(e.label)
              : Text(
                  AppLocalizations.of(context).untitled,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
        ),
      );
    }
  }
}

class CounterPeak {
  final int value;
  final DateTime time;

  CounterPeak(this.value, this.time);
}
