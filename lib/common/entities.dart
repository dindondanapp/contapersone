import 'dart:math';

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
