import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';

/// A simple form to create a new counter, possibly specifying capacity
class CounterCreateForm extends StatelessWidget {
  final TextEditingController? capacityController;
  final Function() onSubmit;
  final bool? enabled;

  /// Creates a new counter creation form
  /// The argument `enabled` can be set to `false` to grey out the actions.
  CounterCreateForm(
      {this.capacityController, required this.onSubmit, this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.createCounterCaption,
          textAlign: TextAlign.center,
        ),
        TextField(
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: capacityController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.capacityHint,
            icon: Icon(Icons.people),
          ),
          style: TextStyle(fontSize: 20),
        ),
        Container(
          height: 20,
        ),
        ElevatedButton.icon(
          onPressed: (enabled != null && enabled!) ? onSubmit : null,
          label: Text(AppLocalizations.of(context)!.createCounterButton),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
