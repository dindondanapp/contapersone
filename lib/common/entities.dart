import 'dart:convert';
import 'dart:math';

// This file containes miscellaneous entities

class CounterToken {
  final String _value;

  CounterToken([int length = 32]) : _value = _generateToken();
  CounterToken.fromString(String value) : _value = value;

  static String _generateToken([int length = 32]) {
    final values =
        List<int>.generate(length, (i) => Random.secure().nextInt(256));
    return base64Url.encode(values);
  }

  String toString() {
    return _value;
  }
}
