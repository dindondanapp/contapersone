import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contapersone/common/show_error_dialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../common/entities.dart';
import '../common/palette.dart';
import '../share_screen/share_screen.dart';

/// A screen with a simple counter, synchronized with Firebase Cloud Firestore
class CounterScreen extends StatefulWidget {
  final CounterToken _counterToken;

  CounterScreen(this._counterToken);

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  var _subcounterTotal = Stream.value(0);
  var _status = CounterScreenStatus.set_name;
  var _disconnected = false;
  var _controller = TextEditingController();
  String _subcounterId;
  String _label;

  var _counterTotal = Stream.value(0);
  var _capacity = Stream<int>.value(null);

  @override
  void initState() {
    super.initState();

    final documentStream = FirebaseFirestore.instance
        .collection('counters')
        .doc(widget._counterToken.toString())
        .snapshots();

    _counterTotal = documentStream
        .map<int>((DocumentSnapshot event) => event['total'])
        .distinct();

    _capacity = documentStream
        .map<int>((DocumentSnapshot event) => event['capacity'])
        .distinct();

    _counterTotal.listen((event) {
      if (_disconnected) {
        setState(() {
          _disconnected = false;
        });
      }
    });
  }

  // Send a +1 event to firestore
  void _updateCounter(int increment) {
    setState(() {
      if (_subcounterId == null) {
        return;
      }

      if (increment == 0) {
        return;
      }

      final update = increment > 0
          ? {
              "add_events": FieldValue.arrayUnion(
                  List.filled(increment.abs(), Timestamp.now().toString()))
            }
          : {
              "subtract_events": FieldValue.arrayUnion(
                  List.filled(increment.abs(), Timestamp.now().toString()))
            };

      // TODO: Timestamp.now() should be passed directly, without converting to string
      // waiting for fix (https://github.com/flutter/flutter/issues/15252)
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget._counterToken.toString())
          .collection('subcounters')
          .doc(_subcounterId)
          .update(update)
          .timeout(Duration(seconds: 10))
          .then((value) => setState(() => _disconnected = false))
          .catchError((error) => setState(() => _disconnected = true));
    });
  }

  // Create a new subcounter and initialize the total stream
  void _submitEntranceName(String text) async {
    FirebaseAnalytics()
        .logEvent(name: 'submit_entrance_name', parameters: null);
    _label = text != '' ? text : null;

    setState(() {
      _status = CounterScreenStatus.loading;
    });

    try {
      final ref = await FirebaseFirestore.instance
          .collection('counters')
          .doc(widget._counterToken.toString())
          .collection('subcounters')
          .add({
        'label': _label,
        'add_events': [],
        'subtract_events': []
      }).timeout(Duration(seconds: 10));

      _subcounterId = ref.id;

      final documentStream = FirebaseFirestore.instance
          .collection('counters')
          .doc(widget._counterToken.toString())
          .collection('subcounters')
          .doc(_subcounterId)
          .snapshots();

      _subcounterTotal = documentStream.map<int>((DocumentSnapshot event) {
        return (event['add_events'] as List).length -
            (event['subtract_events'] as List).length;
      });

      setState(() {
        _status = CounterScreenStatus.ready;
      });
    } catch (error) {
      print(error);

      showErrorDialog(
        context: context,
        title: 'Errore di connessione',
        text: 'Verifica la connessione di rete e riprova.',
        onRetry: () => _submitEntranceName(text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contapersone'),
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
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 60,
                child: StreamBuilder<int>(
                  stream: _counterTotal,
                  initialData: 0,
                  builder: (BuildContext context, total) => StreamBuilder<int>(
                    stream: _capacity,
                    builder: (BuildContext context, capacity) =>
                        _buildStyledTotal(
                      total.data,
                      capacity: capacity.data,
                      disconnected: _disconnected,
                    ),
                  ),
                ),
              ),
              Text(
                'Conteggio totale',
                textAlign: TextAlign.center,
              ),
              Container(
                height: 20,
              ),
              Card(
                margin: EdgeInsets.all(0),
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: () {
                      if (_status == CounterScreenStatus.ready) {
                        return Column(
                          children: [
                            StreamBuilder<int>(
                              stream: _subcounterTotal,
                              initialData: 0,
                              builder: (BuildContext context, total) =>
                                  _buildStyledTotal(total.data),
                            ),
                            Text(
                              _label == null ? 'Questo ingresso' : _label,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Prima di iniziare il conteggio, scegli un nome per questo contatore:',
                              softWrap: true,
                            ),
                            TextField(
                              onSubmitted: _submitEntranceName,
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Nome del contatore (facoltativo)',
                              ),
                            ),
                            Container(
                              height: 20,
                            ),
                            RaisedButton.icon(
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Avvia',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Palette.primary,
                              onPressed: _status == CounterScreenStatus.set_name
                                  ? () => _submitEntranceName(_controller.text)
                                  : null,
                            ),
                          ],
                        );
                      }
                    }()),
              ),
              Container(
                height: 10,
              ),
              () {
                if (_status == CounterScreenStatus.ready) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: RaisedButton(
                            child: Icon(Icons.remove),
                            onPressed: () => _updateCounter(-1),
                            color: Colors.grey[300],
                          ),
                          flex: 3,
                        ),
                        Container(width: 10),
                        Expanded(
                          child: RaisedButton(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 50,
                            ),
                            onPressed: () => _updateCounter(1),
                            color: Palette.primary,
                          ),
                          flex: 7,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              }()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTotal(int total,
      {int capacity, bool disconnected = false}) {
    Color color = disconnected ? Colors.grey : Colors.black;
    if (capacity != null) {
      if (total >= capacity) {
        color = Colors.red;
      } else if (total >= 0.9 * capacity) {
        color = Colors.orange;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: total.toString(),
            children: [
              TextSpan(
                text: capacity != null ? '/$capacity' : '',
                style: TextStyle(fontSize: 50, color: Palette.primary),
              ),
            ],
            style: TextStyle(fontSize: 50, color: color),
          ),
          textAlign: TextAlign.center,
        ),
        ...(disconnected
            ? [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.cloud_off,
                  color: Colors.grey,
                  size: 40,
                )
              ]
            : []),
      ],
    );
  }

  void _openShareScreen() {
    FirebaseAnalytics()
        .logEvent(name: 'open_share_from_counter', parameters: null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShareScreen(
          widget._counterToken,
          startCounterButton: true,
        ),
      ),
    );
  }
}

enum CounterScreenStatus { set_name, loading, ready }
