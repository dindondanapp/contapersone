import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// This file containes miscellaneous entities that are needed across multiple screens

/// Unique identifier for a shared counter in the database
class CounterToken {
  final String _value;

  /// Create a new shared counter identifier, represented by a 32 characters
  /// hex [String]
  CounterToken() : _value = _generateToken(32);

  /// Create a counter identifier from its given [String] representation
  // TODO: add format check (but be careful with cross-version sharing)
  CounterToken.fromString(this._value);

  static String _generateToken([int length = 32]) {
    final random = Random.secure();
    return List<String>.generate(
        length, (i) => random.nextInt(16).toRadixString(16)).join();
  }

  /// Return a string representation of the shared counter identifier.
  /// The output can be parsed with the [fromString] constructor.
  String toString() {
    return _value;
  }
}

/// Set of minimal data for representing the state of a counter
class CounterData {
  final CounterToken token;
  final Timestamp lastUpdated;
  final int peak;
  final int total;
  final int capacity;
  final List<SubcounterData> subcounters;

  CounterData(
    this.token, {
    this.lastUpdated,
    this.peak,
    this.total,
    this.capacity,
    this.subcounters,
  });
}

/// Set of minimal data for representing the state of a subcounter
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
