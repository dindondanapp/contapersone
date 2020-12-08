import 'package:flutter/material.dart';

/// A simple form to create a new counter, possibly specifying capacity
class CounterCreate extends StatelessWidget {
  final TextEditingController capacityController;
  final Function onSubmit;
  final bool enabled;

  /// Create a new counter creation form
  CounterCreate({this.capacityController, this.onSubmit, this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crea un nuovo contapersone condiviso',
          textAlign: TextAlign.center,
        ),
        TextField(
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: capacityController,
          decoration: InputDecoration(
            hintText: 'Capienza (facoltativa)',
            icon: Icon(Icons.people),
          ),
          style: TextStyle(fontSize: 20),
        ),
        Container(
          height: 20,
        ),
        RaisedButton.icon(
          onPressed: enabled ? onSubmit : null,
          label: Text('Crea nuovo contapersone'),
          icon: Icon(Icons.add),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
