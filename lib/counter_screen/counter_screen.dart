import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/home_screen/history.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/auth.dart';
import '../common/entities.dart';
import '../common/palette.dart';
import '../counter_screen/count_display.dart';
import '../share_screen/share_screen.dart';

/// A screen with a simple counter, synchronized with Firebase Cloud Firestore
class CounterScreen extends StatefulWidget {
  final CounterToken token;
  final Auth auth;
  final CounterData initData;

  CounterScreen({@required this.token, @required this.auth, this.initData});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  var _disconnected = false;
  var _subcounterLabelController = TextEditingController();
  String _thisSubcounterId;

  /// Lock used to prevent remote updates of the subcounter label while editing
  bool _subcounterLabelLock = false;

  int _capacity;
  List<SubcounterData> _otherSubcounters = [];
  List<dynamic> _addEvents = [];
  List<dynamic> _subtractEvents = [];

  int _oldCounterTotal;

  int get _thisSubcounterCount => _addEvents.length - _subtractEvents.length;
  int get _otherSubcountersTotal => _otherSubcounters.fold<int>(
        0,
        (previousValue, element) => previousValue + element.count,
      );
  int get _counterTotal => _thisSubcounterCount + _otherSubcountersTotal;

  String get _subcounterLabel => _subcounterLabelController.text;
  set _subcounterLabel(String label) {
    if (!_subcounterLabelLock) {
      _subcounterLabelController.text = label;
    }
  }

  final listeners = [];

  @override
  void initState() {
    super.initState();

    _thisSubcounterId = widget.auth.getCurrentUser().uid;

    if (widget.initData != null) {
      final thisSubcounterData = widget.initData.subcounters
          .firstWhere((element) => element.id == _thisSubcounterId);
      final otherSubcountersData = widget.initData.subcounters
          .where((element) => element.id != _thisSubcounterId)
          .toList();

      _addEvents = thisSubcounterData.count > 0
          ? List.filled(thisSubcounterData.count.abs(), null)
          : [];
      _subtractEvents = thisSubcounterData.count < 0
          ? List.filled(thisSubcounterData.count.abs(), null)
          : [];
      _otherSubcounters = otherSubcountersData;

      print(_thisSubcounterCount);
      print(_otherSubcountersTotal);
      print(_counterTotal);
    }

    listeners.add(
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget.token.toString())
          .snapshots()
          .distinct()
          .listen((event) {
        setState(() {
          _capacity = event['capacity'];
          _disconnected = false;

          if (event.data().containsKey('subtotals')) {
            _otherSubcounters = (event.data()['subtotals']
                    as Map<String, dynamic>)
                .map(
                  (id, value) => MapEntry(
                    id,
                    SubcounterData(
                      id: id,
                      count: value['count'] as int,
                      label: value['label'] as String,
                      lastUpdated: value['lastUpdated'] as Timestamp,
                    ),
                  ),
                )
                .values
                .where((element) => element.id != _thisSubcounterId)
                .toList()
                  ..sort(
                      (a, b) => b.lastUpdated.seconds - a.lastUpdated.seconds);

            final thisSubconterData = _otherSubcounters.firstWhere(
                (element) => element.id == _thisSubcounterId,
                orElse: () => null);
            if (thisSubconterData != null) {
              _subcounterLabel = thisSubconterData.label;
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
            _addEvents = event.data()['add_events'] as List<dynamic> ?? [];
            _subtractEvents =
                event.data()['subtract_events'] as List<dynamic> ?? [];
            _subcounterLabel = event.data()['label'] as String ?? null;

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

  // Create a new subcounter and initialize the total stream
  void _submitEntranceName(String label) async {
    print('Entrance submitted');

    FirebaseAnalytics().logEvent(name: 'submit_entrance_name');

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

  // Vibration or sound feedback
  bool giveFeedbackIfNeeded() {
    // Simple haptic feedback when the total count changes
    final hapticFeedback =
        _oldCounterTotal != null && _counterTotal != _oldCounterTotal;

    // Strong vibration when the total count increases above 90% of capacity
    // TODO: Intergrate the 90% threshold with CountDisplay color
    final vibrate = _oldCounterTotal != null &&
        _capacity != null &&
        _counterTotal >= _capacity * 0.9 &&
        _counterTotal > _oldCounterTotal;

    _oldCounterTotal = _counterTotal;

    if (vibrate) {
      HapticFeedback.vibrate();
    } else if (hapticFeedback) {
      HapticFeedback.heavyImpact();
    }

    return vibrate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appBarDefault),
        backgroundColor: Palette.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _openShareScreen,
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
            CountDisplay(
              otherSubcountersData: _otherSubcounters,
              thisSubcounterData: SubcounterData(
                id: _thisSubcounterId,
                count: _thisSubcounterCount,
                label: _subcounterLabel,
                lastUpdated: Timestamp.now(),
              ),
              isDisconnected: _disconnected,
              total: _counterTotal,
              capacity: _capacity,
              onEditLabel: _openEditLabelDialog,
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
                        primary: Colors.grey[300],
                        onPrimary: Colors.grey[600],
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
            title: Text(AppLocalizations.of(context).editEntranceLabelTitle),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: FocusScope(
                    child: TextField(
                      controller: _subcounterLabelController,
                      onSubmitted: (_) => _submitEditLabelDialog(),
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context).editEntranceLabelHint,
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context).cancel),
                onPressed: _dismissEditLabelDialog,
              ),
              TextButton(
                child: Text(AppLocalizations.of(context).confirm),
                onPressed: _submitEditLabelDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitEditLabelDialog() {
    _submitEntranceName(_subcounterLabelController.text);
    Navigator.of(context).pop();
  }

  void _dismissEditLabelDialog() {
    Navigator.of(context).pop();
  }

  void _openShareScreen() {
    FirebaseAnalytics()
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

  @override
  void dispose() {
    super.dispose();
    listeners.forEach((element) => element.cancel());
  }
}

/// All the data about the current state of a subcounter
class SubcounterData {
  final String label;
  final String id;
  final int count;
  final Timestamp lastUpdated;

  /// Create an object with all the data about the current state of a subcounter
  SubcounterData(
      {@required this.lastUpdated,
      @required this.label,
      @required this.id,
      @required this.count});
}
