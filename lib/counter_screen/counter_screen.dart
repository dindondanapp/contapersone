import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/stats_screen/stats_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:vibration/vibration.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/palette.dart';
import '../counter_screen/count_display.dart';
import '../share_screen/share_screen.dart';

/// A screen with a simple counter, synchronized with Firebase Cloud Firestore
class CounterScreen extends StatefulWidget {
  final CounterToken token;
  final Auth auth;
  final CounterData? initData;

  CounterScreen({required this.token, required this.auth, this.initData});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  var _disconnected = false;
  var _subcounterLabelController = TextEditingController();
  var _capacityController = TextEditingController();
  var _vibrationEnabled = true;
  var _isUserCreator = false;
  var _reverseCountDisplay = false;

  String? _thisSubcounterId;

  /// Lock used to prevent remote updates of the subcounter label while editing
  bool _subcounterLabelLock = false;

  int? _capacity;
  List<SubcounterData> _otherSubcounters = [];
  List<dynamic> _addEvents = [];
  List<dynamic> _subtractEvents = [];

  int? _oldCounterTotal;

  int get _thisSubcounterCount => _addEvents.length - _subtractEvents.length;
  int get _otherSubcountersTotal => _otherSubcounters.fold<int>(
        0,
        (previousValue, element) => previousValue + element.count,
      );
  int get _counterTotal => _thisSubcounterCount + _otherSubcountersTotal;

  String? get _subcounterLabel => _subcounterLabelController.text;
  set _subcounterLabel(String? label) {
    if (!_subcounterLabelLock) {
      _subcounterLabelController.text = label ?? "";
    }
  }

  final listeners = [];

  @override
  void initState() {
    super.initState();

    _thisSubcounterId = widget.auth.getCurrentUser()?.uid;

    if (widget.initData != null) {
      final thisSubcounterData =
          widget.initData!.subcounters.cast<SubcounterData?>().firstWhere(
                (element) => element?.id == _thisSubcounterId,
                orElse: () => null,
              );
      final otherSubcountersData = widget.initData!.subcounters
          .where((element) => element.id != _thisSubcounterId)
          .toList();

      _addEvents = thisSubcounterData != null && thisSubcounterData.count > 0
          ? List.filled(thisSubcounterData.count.abs(), null)
          : [];
      _subtractEvents =
          thisSubcounterData != null && thisSubcounterData.count < 0
              ? List.filled(thisSubcounterData.count.abs(), null)
              : [];
      _otherSubcounters = otherSubcountersData;
    }

    listeners.add(
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget.token.toString())
          .snapshots()
          .distinct()
          .listen((event) {
        setState(() {
          _capacity = event.get('capacity');
          _capacityController.text =
              _capacity != null ? _capacity.toString() : '';
          _disconnected = false;
          _isUserCreator = event.data()!.containsKey('creator') &&
              event.data()!['creator'] == widget.auth.userId;

          if (event.data()!.containsKey('subtotals')) {
            _otherSubcounters = (event.data()!['subtotals']
                    as Map<String, dynamic>)
                .map(
                  (id, value) => MapEntry(
                    id,
                    SubcounterData(
                      id: id,
                      count: value['count'] as int,
                      label: value['label'] as String?,
                      lastUpdated: value['lastUpdated'] as Timestamp,
                    ),
                  ),
                )
                .values
                .where((element) => element.id != _thisSubcounterId)
                .toList()
              ..sort((a, b) => b.lastUpdated.seconds - a.lastUpdated.seconds);

            final thisSubconterData = _otherSubcounters
                .cast<SubcounterData?>()
                .firstWhere((element) => element?.id == _thisSubcounterId,
                    orElse: () => null);
            if (thisSubconterData != null) {
              _subcounterLabel = thisSubconterData!.label;
            }
          }

          giveFeedbackIfNeeded();
        });
      }),
    );

    listeners.add(
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget.token.toString())
          .collection('subcounters')
          .doc(_thisSubcounterId)
          .snapshots()
          .distinct()
          .listen((event) {
        if (event.exists) {
          setState(() {
            _addEvents = event.data()!['add_events'] as List<dynamic>? ?? [];
            _subtractEvents =
                event.data()!['subtract_events'] as List<dynamic>? ?? [];
            _subcounterLabel = event.data()!['label'] as String? ?? null;

            giveFeedbackIfNeeded();
          });
        }
      }),
    );
  }

  // Send an increment event to firestore
  void _updateCounter(int increment) {
    if (_thisSubcounterId == null) {
      return;
    }

    if (increment == 0) {
      return;
    }

    Map<String, dynamic> update = increment > 0
        ? {
            "add_events": [
              ..._addEvents,
              ...List.filled(increment.abs(), Timestamp.now())
            ],
          }
        : {
            "subtract_events": [
              ..._subtractEvents,
              ...List.filled(increment.abs(), Timestamp.now())
            ],
          };

    FirebaseFirestore.instance
        .collection('counters')
        .doc(widget.token.toString())
        .collection('subcounters')
        .doc(_thisSubcounterId)
        .set(update, SetOptions(merge: true))
        .timeout(Duration(seconds: 10))
        .then((value) => setState(() => _disconnected = false))
        .catchError((error) => setState(() => _disconnected = true));
  }

  // Set the subcounter label
  void _submitSubcounterLabel(String label) async {
    FirebaseAnalytics.instance.logEvent(name: 'submit_entrance_name');

    FirebaseFirestore.instance
        .collection('counters')
        .doc(widget.token.toString())
        .collection('subcounters')
        .doc(_thisSubcounterId)
        .set(
      {'label': label},
      SetOptions(merge: true),
    );
  }

  // Set the counter capacity
  void _submitCapacity(int? capacity) async {
    FirebaseAnalytics.instance.logEvent(name: 'submit_capacity');

    FirebaseFirestore.instance
        .collection('counters')
        .doc(widget.token.toString())
        .set(
      {'capacity': capacity},
      SetOptions(merge: true),
    );
  }

  // Vibration or sound feedback
  bool giveFeedbackIfNeeded() {
    // Simple haptic feedback when the total count changes
    final lightVibration =
        _oldCounterTotal != null && _counterTotal != _oldCounterTotal;

    // Strong vibration when the total count increases above 90% of capacity
    // TODO: Intergrate the 90% threshold with CountDisplay color
    final strongVibration = _oldCounterTotal != null &&
        _capacity != null &&
        _counterTotal >= _capacity! * 0.9 &&
        _counterTotal > _oldCounterTotal!;

    _oldCounterTotal = _counterTotal;

    if (_vibrationEnabled) {
      if (strongVibration) {
        Vibration.vibrate();
      } else if (lightVibration) {
        HapticFeedback.heavyImpact();
      }
    }

    return strongVibration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appBarDefault),
        backgroundColor: Palette.primary,
        actions: [
          PopupMenuButton<void Function()>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text(AppLocalizations.of(context)!.shareCounter),
                ),
                value: _openShareScreen,
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.show_chart),
                  title: Text(AppLocalizations.of(context)!.statsScreenTitle),
                ),
                value: _openStatsScreen,
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text(AppLocalizations.of(context)!.editCapacityTitle),
                ),
                value: _openEditCapacityDialog,
              ),
              ...(_isUserCreator
                  ? [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.refresh),
                          title:
                              Text(AppLocalizations.of(context)!.resetCounter),
                        ),
                        value: _resetCounter,
                      )
                    ]
                  : []),
              PopupMenuDivider(),
              PopupMenuItem(
                child: _vibrationEnabled
                    ? ListTile(
                        leading: Icon(Icons.vibration),
                        title: Text(
                            AppLocalizations.of(context)!.disableVibration),
                      )
                    : ListTile(
                        leading: Icon(Icons.vibration),
                        title:
                            Text(AppLocalizations.of(context)!.enableVibration),
                      ),
                value: _toggleVibration,
              ),
            ],
            onSelected: (value) => value(),
          ),
        ],
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              child: CountDisplay(
                otherSubcountersData: _otherSubcounters,
                thisSubcounterData: SubcounterData(
                  id: _thisSubcounterId!,
                  count: _thisSubcounterCount,
                  label: _subcounterLabel,
                  lastUpdated: Timestamp.now(),
                ),
                isDisconnected: _disconnected,
                total: _counterTotal,
                capacity: _capacity,
                onEditLabel: _openEditLabelDialog,
                reverse: _reverseCountDisplay,
                onTotalTap: () => {
                  setState(() {
                    _reverseCountDisplay = !_reverseCountDisplay;
                  })
                },
              ),
            ),
            Container(
              height: 20,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Icon(Icons.remove),
                      onPressed: () => _updateCounter(-1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    flex: 3,
                  ),
                  Container(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 50,
                      ),
                      onPressed: () => _updateCounter(1),
                    ),
                    flex: 7,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openEditLabelDialog() {
    // Lock label remote updates
    _subcounterLabelLock = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _subcounterLabelLock = false; // Release the lock before popping
            return true;
          },
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.editEntranceLabelTitle),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: FocusScope(
                    child: TextField(
                      controller: _subcounterLabelController,
                      onSubmitted: (_) => _submitEditLabelDialog(),
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.editEntranceLabelHint,
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: _dismissEditLabelDialog,
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.confirm),
                onPressed: _submitEditLabelDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditCapacityDialog() {
    // Lock label remote updates
    _subcounterLabelLock = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _subcounterLabelLock = false; // Release the lock before popping
            return true;
          },
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.editCapacityTitle),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: FocusScope(
                    child: TextField(
                      controller: _capacityController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      onSubmitted: (_) => _submitEditCapacityDialog(),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.capacityHint,
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: _dismissEditCapacityDialog,
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.confirm),
                onPressed: _submitEditCapacityDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitEditLabelDialog() {
    _submitSubcounterLabel(_subcounterLabelController.text);
    Navigator.of(context).pop();
  }

  void _dismissEditLabelDialog() {
    Navigator.of(context).pop();
  }

  void _submitEditCapacityDialog() {
    _submitCapacity(int.tryParse(_capacityController.text));
    Navigator.of(context).pop();
  }

  void _dismissEditCapacityDialog() {
    Navigator.of(context).pop();
  }

  void _openShareScreen() {
    FirebaseAnalytics.instance
        .logEvent(name: 'open_share_from_counter', parameters: null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShareScreen(
          token: widget.token,
          auth: widget.auth,
          startCounterButton: true,
        ),
      ),
    );
  }

  void _openStatsScreen() {
    FirebaseAnalytics.instance
        .logEvent(name: 'open_stats_from_counter', parameters: null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatsScreen(
          token: widget.token,
          auth: widget.auth,
        ),
      ),
    );
  }

  void _toggleVibration() {
    setState(() {
      // TODO: this should be made persistent through Shared Preferences
      _vibrationEnabled = !_vibrationEnabled;
    });
  }

  /// Resets the counter by removing all events from all subcounters
  void _resetCounter() async {
    if (await _resetConfirmDialog()) {
      FirebaseAnalytics.instance
          .logEvent(name: 'reset_counter', parameters: null);

      final subcounterIds = <String>[
        _thisSubcounterId!,
        ..._otherSubcounters.map((e) => e.id)
      ];

      final WriteBatch batch = FirebaseFirestore.instance.batch();

      subcounterIds.forEach((id) {
        batch.update(
          FirebaseFirestore.instance
              .collection('counters')
              .doc(widget.token.toString())
              .collection('subcounters')
              .doc(id),
          {
            'add_events': [],
            'subtract_events': [],
          },
        );
      });

      await batch.commit();
    }
  }

  Future<bool> _resetConfirmDialog() {
    final completer = Completer<bool>();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.resetConfirmTitle),
          content: Text(AppLocalizations.of(context)!.resetConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(true);
              },
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
    super.dispose();
    listeners.forEach((element) => element.cancel());
  }
}
