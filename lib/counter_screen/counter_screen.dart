import 'package:cloud_firestore/cloud_firestore.dart';
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
  var _controller = TextEditingController();
  String _subcounterId;
  String _label;

  var _counterTotal = Stream.value(0);
  var _capacity = Stream<int>.value(null);

  @override
  void initState() {
    print("Subcounter intialized for:");
    print("CounterID ${widget._counterToken}");
    super.initState();

    var documentStream = FirebaseFirestore.instance
        .collection('counters')
        .doc(widget._counterToken.toString())
        .snapshots();

    _counterTotal = documentStream
        .map<int>((DocumentSnapshot event) => event['total'])
        .distinct();

    _capacity = documentStream
        .map<int>((DocumentSnapshot event) => event['capacity'])
        .distinct();
  }

  void _incrementCounter() {
    setState(() {
      if (_subcounterId == null) {
        return;
      }

      // TODO: Timestamp.now() should be passed directly, without converting to string
      // waiting for fix (https://github.com/flutter/flutter/issues/15252)
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget._counterToken.toString())
          .collection('subcounters')
          .doc(_subcounterId)
          .update({
        "add_events": FieldValue.arrayUnion([Timestamp.now().toString()])
      });
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_subcounterId == null) {
        return;
      }

      // TODO: same as before
      FirebaseFirestore.instance
          .collection('counters')
          .doc(widget._counterToken.toString())
          .collection('subcounters')
          .doc(_subcounterId)
          .update({
        "subtract_events": FieldValue.arrayUnion([Timestamp.now().toString()])
      });
    });
  }

  void _submitEntranceName(String text) {
    FirebaseAnalytics()
        .logEvent(name: 'submit_entrance_name', parameters: null);
    _label = text != '' ? text : null;
    FirebaseFirestore.instance
        .collection('counters')
        .doc(widget._counterToken.toString())
        .collection('subcounters')
        .add({'label': _label, 'add_events': [], 'subtract_events': []}).then(
            (ref) {
      _subcounterId = ref.id;
      print("New subcounter created.");
      print(_subcounterId);

      var documentStream = FirebaseFirestore.instance
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
        _status = CounterScreenStatus.loaded;
      });
    }).catchError((e) {
      print('Firestore error');
      print(e);
    });
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
              StreamBuilder<int>(
                stream: _counterTotal,
                initialData: 0,
                builder: (BuildContext context, total) => StreamBuilder<int>(
                  stream: _capacity,
                  builder: (BuildContext context, capacity) =>
                      _buildStyledTotal(
                    total.data,
                    capacity: capacity.data,
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
                      if (_status == CounterScreenStatus.set_name) {
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
                              onPressed: () {
                                _submitEntranceName(_controller.text);
                              },
                            ),
                          ],
                        );
                      } else {
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
                      }
                    }()),
              ),
              Container(
                height: 10,
              ),
              () {
                if (_status == CounterScreenStatus.loaded) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: RaisedButton(
                            child: Icon(Icons.remove),
                            onPressed: _decrementCounter,
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
                            onPressed: _incrementCounter,
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

  Widget _buildStyledTotal(int total, {int capacity}) {
    Color color = Colors.black;
    if (capacity != null) {
      if (total >= capacity) {
        color = Colors.red;
      } else if (total >= 0.9 * capacity) {
        color = Colors.orange;
      }
    }

    return RichText(
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

enum CounterScreenStatus { set_name, loading, loaded }
