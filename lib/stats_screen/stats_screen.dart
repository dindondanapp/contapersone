import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:contapersone/common/palette.dart';
import 'package:contapersone/stats_screen/stats_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/subjects.dart';
import 'package:share/share.dart';
import 'package:universal_html/html.dart' as html;

import '../common/auth.dart';
import '../common/entities.dart';

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
  BehaviorSubject<TimeSeriesCollection> _timeSeriesStream =
      BehaviorSubject.seeded(TimeSeriesCollection.empty());
  List<StreamSubscription> subscriptions = [];
  final _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    widget.auth.addListener(_updateAuth);

    _updateStreams();
  }

  void _updateAuth() {
    if (widget.auth.userId != _userId) {
      _userId = widget.auth.userId;
      _updateStreams();
    }
  }

  _updateStreams() {
    setState(() {
      if (widget.auth.userId == null) {
        _counterDataStream = Stream.empty();
        _timeSeriesStream.add(TimeSeriesCollection.empty());
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
              creator: doc.data()['creator'],
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

        subscriptions.add(
          subcountersStream
              .map((event) => TimeSeriesCollection.fromDocs(event.docs))
              .listen(
                (event) => _timeSeriesStream.add(event),
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).statsScreenTitle),
        backgroundColor: Palette.primary,
        actions: [_buildShareOrDownloadAction()],
      ),
      body: _buildCounterStateWidget(),
    );
  }

  Widget _buildCounterStateWidget() {
    return StreamBuilder<CounterData>(
      stream: _counterDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final capacity = snapshot.data.capacity;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: StreamBuilder<TimeSeriesCollection>(
                    stream: _timeSeriesStream,
                    initialData: TimeSeriesCollection.empty(),
                    builder: (context, snapshot) {
                      return StatsChart(
                        timeSeries: snapshot.data,
                        capacity: capacity,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOrDownloadAction() {
    if (kIsWeb) {
      return IconButton(
        icon: Icon(Icons.file_download),
        onPressed: _downloadFile,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.share),
        onPressed: _shareFile,
        key: _shareButtonKey,
      );
    }
  }

  Future<void> _shareFile() async {
    final fileName = 'stats.csv';
    final dir = Directory.systemTemp.createTempSync();
    final file = File("${dir.path}/$fileName")..createSync();

    file.writeAsStringSync(await _generateCSV());

    final RenderBox box = _shareButtonKey.currentContext.findRenderObject();

    await Share.shareFiles(
      [file.path],
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _downloadFile() async {
    final fileName = 'stats.csv';
    final encodedContent = base64Encode(utf8.encode(await _generateCSV()));
    final mimeType = 'text/csv';
    final anchor = html.AnchorElement(
        href: "data:$mimeType;charset=utf8;base64,$encodedContent")
      ..setAttribute("download", fileName);
    anchor.click();
  }

  Future<String> _generateCSV() async {
    final timeSeriesList = _timeSeriesStream.valueWrapper.value.subcounters;

    // Get all the sorted time instants of all the points.
    // Each instant will correspond to a table row.
    final List<DateTime> times = timeSeriesList
        .map<List<DateTime>>(
          (timeSeries) =>
              timeSeries.points.map<DateTime>((point) => point.time).toList(),
        )
        .expand((list) => list)
        .toSet()
        .toList();

    times.sort((a, b) => a.difference(b).inMilliseconds);

    // The heading row has one empty cell for the time column and then one
    // or more cells, each with the label of a subcounter
    final String headingRow = [
      '',
      ...timeSeriesList.map<String>(
        (timeSeries) =>
            (timeSeries.label != null && timeSeries.label.isNotEmpty)
                ? timeSeries.label
                : AppLocalizations.of(context).untitled,
      ),
    ].join(',');

    // Generate a table row for each instant
    final List<String> bodyRows = [];
    final pointIndexes = List.filled(timeSeriesList.length, 0);
    times.forEach(
      (time) {
        // Add a row to the table body with the values of all the subcounter
        // at the the current point indexes (that represent the count at the
        // cycle `time`)
        bodyRows.add(
          // The first column is the time in ISO-8601 format
          time.toIso8601String() +
              ',' +
              // The subsequent columns are the counts of each subcounter
              pointIndexes
                  .mapIndexed<String>(
                    (seriesIndex, pointIndex) => timeSeriesList[seriesIndex]
                        .points[min(
                          pointIndex,
                          timeSeriesList[seriesIndex].points.length - 1,
                        )]
                        .count
                        .toString(),
                  )
                  .join(','),
        );

        // Update point indexes according to the cycle `time`
        timeSeriesList.forEachIndexed(
          (seriesIndex, timeSeries) {
            pointIndexes[seriesIndex] += timeSeries.points
                .skip(pointIndexes[seriesIndex])
                .takeWhile((point) => point.time.isBefore(time))
                .length;
          },
        );
      },
    );

    return [headingRow, ...bodyRows].join('\n');
  }

  @override
  void dispose() {
    subscriptions.forEach((element) => element.cancel());
    _timeSeriesStream.close();
    widget.auth.removeListener(_updateAuth);

    super.dispose();
  }
}
