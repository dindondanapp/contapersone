import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../common/extensions.dart';

class StatsChart extends StatefulWidget {
  final TimeSeriesCollection timeSeries;
  final int? capacity;

  StatsChart({
    Key? key,
    required this.timeSeries,
    this.capacity,
  }) : super(key: key);

  @override
  _StatsChartState createState() {
    return _StatsChartState();
  }
}

class _StatsChartState extends State<StatsChart> {
  static const _maxDefaultWindow = Duration(minutes: 30);
  static const _minDefaultWindow = Duration(minutes: 5);
  static const _palette = [
    Colors.green,
    Colors.deepOrange,
    Colors.purple,
    Colors.lightGreen,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.blueGrey,
  ];

  double? autoZoomPosition;
  double? autoZoomFactor;
  double? zoomPosition;
  double? zoomFactor;
  double? upperLimit;
  double? lowerLimit;
  TimeSeries totalTimeSeries = TimeSeries([]);

  _StatsChartState();

  @override
  void didChangeDependencies() {
    _updateTimeSeries();
    zoomFactor = autoZoomFactor;
    zoomPosition = autoZoomPosition;

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(StatsChart oldWidget) {
    _updateTimeSeries();
    super.didUpdateWidget(oldWidget);
  }

  void _updateTimeSeries() {
    totalTimeSeries = TimeSeries.combine(widget.timeSeries.subcounters);

    if (totalTimeSeries.points.length > 10) {
      final totalDuration = totalTimeSeries.points.last.time
          .difference(totalTimeSeries.points.first.time);
      final window = totalDuration > _minDefaultWindow
          ? totalDuration < _maxDefaultWindow
              ? totalDuration
              : _maxDefaultWindow
          : _minDefaultWindow;

      autoZoomPosition = 1;

      autoZoomFactor = (window.inMilliseconds / totalDuration.inMilliseconds)
          .clamp(0.0, 1.0);

      // TODO: use a more efficient algorithm
      final minPoint = [totalTimeSeries, ...widget.timeSeries.subcounters]
          .expand<StatChartPoint>((element) => element.points)
          .reduce((a, b) => a.count < b.count ? a : b);

      final maxPoint = [totalTimeSeries, ...widget.timeSeries.subcounters]
          .expand((element) => element.points)
          .reduce((a, b) => a.count > b.count ? a : b);

      final double minCount = [
        0.0,
        minPoint.count.toDouble(),
      ].reduce(min);

      final double maxCount = [
        (widget.capacity ?? 0).toDouble(),
        maxPoint.count.toDouble(),
      ].reduce(max);

      final countDelta = maxCount - minCount;
      final maxDeltaStep =
          pow(10, ((log(countDelta) / ln10) - 1).floor()).toDouble();

      upperLimit = ((maxCount / maxDeltaStep) + 1).ceil() * maxDeltaStep;
      lowerLimit = ((minCount / maxDeltaStep) - 1).floor() * maxDeltaStep;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalTimeSeries.points.length > 10) {
      return _buildFilledChart();
    } else {
      return _buildEmptyChart();
    }
  }

  Widget _buildFilledChart() {
    final timeString = totalTimeSeries.points.length > 0
        ? AppLocalizations.of(context)!.lastUpdate +
            ': ' +
            totalTimeSeries.points.last.time
                .asStrictlyPast()
                .toHumanString(context: context)
        : '';

    return SfCartesianChart(
      enableAxisAnimation: false,
      series: _buildChartSeries().toList()
          as List<CartesianSeries<dynamic, dynamic>>,
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.minutes,
        dateFormat: DateFormat.Hm(),
        initialZoomPosition: zoomPosition ?? 1,
        initialZoomFactor: zoomFactor ?? 1,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
        title: AxisTitle(
          text: timeString,
          textStyle: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
      primaryYAxis: NumericAxis(
        enableAutoIntervalOnZooming: false,
        minimum: lowerLimit,
        maximum: upperLimit,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        plotBands: [
          ...widget.capacity != null
              ? [
                  PlotBand(
                    start: widget.capacity,
                    color: Colors.red,
                    text: widget.capacity.toString(),
                    verticalTextAlignment: TextAnchor.end,
                    textStyle: TextStyle(color: Colors.red),
                    opacity: 0.1,
                  ),
                  PlotBand(
                    start: widget.capacity,
                    end: widget.capacity,
                    borderColor: Colors.red,
                    borderWidth: 2,
                  ),
                ]
              : [],
          PlotBand(
            end: 0,
            color: Colors.black,
            opacity: 0.1,
          ),
          PlotBand(
            start: 0,
            end: 0,
            borderColor: Colors.grey,
            borderWidth: 2,
          ),
        ],
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        animationDuration: 0,
        decimalPlaces: 0,
        elevation: 0,
        color: Theme.of(context).colorScheme.primary,
        textStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      zoomPanBehavior: ZoomPanBehavior(
        zoomMode: ZoomMode.x,
        enablePinching: true,
        enablePanning: true,
        enableMouseWheelZooming: true,
      ),
      legend: Legend(
        isVisible: widget.timeSeries.subcounters.length > 1,
        position: LegendPosition.bottom,
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Stack(
      children: [
        SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.minutes,
            dateFormat: DateFormat.Hm(),
          ),
          primaryYAxis: NumericAxis(
            enableAutoIntervalOnZooming: false,
            interval: 1.0,
            minimum: lowerLimit,
            maximum: upperLimit,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Center(
          child: Text(
            AppLocalizations.of(context)!.notEnoughData,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Iterable<ChartSeries> _buildChartSeries() sync* {
    yield StepLineSeries<StatChartPoint, DateTime>(
      dataSource: totalTimeSeries.points,
      xValueMapper: (point, _) => point.time,
      yValueMapper: (point, _) => point.count,
      color: Theme.of(context).colorScheme.primary,
      width: 4,
      legendItemText: AppLocalizations.of(context)!.chartTotalLabel,
      name: AppLocalizations.of(context)!.chartTotalLabel,
      legendIconType: LegendIconType.circle,
      animationDuration: 0,
    );

    if (widget.timeSeries.subcounters.length > 1) {
      for (int i = 0; i < widget.timeSeries.subcounters.length; i++) {
        final timeseries = widget.timeSeries.subcounters[i];
        yield StepLineSeries<StatChartPoint, DateTime>(
          dataSource: timeseries
              .extrapolateTo(
                start: totalTimeSeries.points.first.time,
                end: totalTimeSeries.points.last.time,
              )
              .points,
          xValueMapper: (point, _) => point.time,
          yValueMapper: (point, _) => point.count,
          color: i < _palette.length ? _palette[i] : _palette.last,
          width: 2,
          legendItemText: timeseries.label != null && timeseries.label != ''
              ? timeseries.label
              : AppLocalizations.of(context)!.untitled,
          name: timeseries.label != null && timeseries.label != ''
              ? timeseries.label
              : AppLocalizations.of(context)!.untitled,
          legendIconType: LegendIconType.circle,
          animationDuration: 0,
        );
      }
    }
  }
}

class StatChartPoint {
  final DateTime time;
  final int count;

  StatChartPoint({required this.time, required this.count});
}

class TimeSeriesCollection {
  final List<TimeSeries> subcounters;

  TimeSeriesCollection(this.subcounters);

  factory TimeSeriesCollection.fromDocs(List<QueryDocumentSnapshot> docs) {
    return TimeSeriesCollection(
      docs.map<TimeSeries>((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final label = data['label'] as String?;
        final addEvents = (data['add_events'] as List<dynamic>? ?? [])
            .whereType<Timestamp>()
            .map((e) => e.toDate())
            .toList();
        final subtractEvents = (data['subtract_events'] as List<dynamic>? ?? [])
            .whereType<Timestamp>()
            .map((e) => e.toDate())
            .toList();

        return TimeSeries.fromEvents(
          label: label,
          addEvents: addEvents,
          subtractEvents: subtractEvents,
        );
      }).toList(),
    );
  }

  factory TimeSeriesCollection.empty() => TimeSeriesCollection([]);
}

class TimeSeries {
  final List<StatChartPoint> points;
  final String? label;

  TimeSeries(this.points, {this.label});

  factory TimeSeries.fromEvents({
    String? label,
    required List<DateTime> addEvents,
    required List<DateTime> subtractEvents,
  }) {
    return TimeSeries(
      _computePoints(addEvents, subtractEvents).toList(),
      label: label,
    );
  }

  factory TimeSeries.combine(List<TimeSeries> addenda, {String? label}) {
    return TimeSeries(
      addenda.fold<Iterable<StatChartPoint>>(
        [],
        (accumulator, addendum) =>
            _addPoints(accumulator, addendum.points).toList(),
      ).toList(),
      label: label,
    );
  }

  TimeSeries extrapolateTo({DateTime? start, DateTime? end}) {
    if (this.points.length > 2) {
      return TimeSeries(
          List.from([
            ...(start != null && start.isBefore(this.points.first.time)
                ? [StatChartPoint(time: start, count: this.points.first.count)]
                : []),
            ...this.points,
            ...(end != null && end.isAfter(this.points.last.time)
                ? [StatChartPoint(time: end, count: this.points.last.count)]
                : []),
          ]),
          label: label);
    } else {
      return TimeSeries(points);
    }
  }

  static Iterable<StatChartPoint> _computePoints(
      List<DateTime> addEvents, List<DateTime> subtractEvents) sync* {
    final Iterable<MapEntry<DateTime, int>> deltaEvents = [
      ...addEvents.map((e) => MapEntry(e, 1)),
      ...subtractEvents.map((e) => MapEntry(e, -1)),
    ]..sort((a, b) => a.key.difference(b.key).inMilliseconds);

    int accumulator = 0;
    DateTime? time;
    for (final deltaEvent in deltaEvents) {
      if (time != null && deltaEvent.key != time) {
        yield StatChartPoint(time: time, count: accumulator);
      }
      time = deltaEvent.key;
      accumulator += deltaEvent.value;
    }

    if (accumulator > 0 && time != null) {
      yield StatChartPoint(time: time, count: accumulator);
    }
  }

  static Iterable<StatChartPoint> _addPoints(
      Iterable<StatChartPoint> a, List<StatChartPoint> b) sync* {
    int skipCount = 0;
    int lastBPointCount = 0;
    int lastAPointCount = 0;
    for (final bPoint in b) {
      final Iterable<StatChartPoint> precedingAPoints = a
          .skip(skipCount)
          .takeWhile((aPoint) => aPoint.time.isBefore(bPoint.time));

      lastAPointCount = precedingAPoints.length > 0
          ? precedingAPoints.last.count
          : lastAPointCount;

      yield* precedingAPoints
          .map(
            (precedingAPoint) => StatChartPoint(
                time: precedingAPoint.time,
                count: precedingAPoint.count + lastBPointCount),
          )
          .toList();

      skipCount += precedingAPoints.length;

      lastBPointCount = bPoint.count;

      yield StatChartPoint(
        time: bPoint.time,
        count: lastAPointCount + bPoint.count,
      );
    }
    yield* a
        .skip(skipCount)
        .takeWhile((value) => true)
        .map(
          (precedingPoint) => StatChartPoint(
              time: precedingPoint.time,
              count: precedingPoint.count + lastBPointCount),
        )
        .toList();
  }
}
