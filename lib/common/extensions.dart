import 'dart:math';

import 'package:flutter/material.dart';

// This file contains miscellaneous extensions

extension ColorToMaterialColor on Color {
  /// Convert the color into a [MaterialColor], creating variations based on lightness
  MaterialColor toMaterialColor() {
    final lightnessMap = {
      050: 1.8,
      100: 1.6,
      200: 1.4,
      300: 1.2,
      400: 1.0,
      500: 0.9,
      600: 0.8,
      700: 0.7,
      800: 0.6,
      900: 0.5,
    };

    return MaterialColor(
      this.value,
      lightnessMap.map<int, Color>(
        (key, multiplier) => MapEntry(
          key,
          _lightnessVariation(multiplier),
        ),
      ),
    );
  }

  /// Create a new color with the given lightness [multiplier]
  Color _lightnessVariation(num multiplier) {
    final base = HSLColor.fromColor(this);
    return base
        .withLightness(
          (base.lightness * multiplier).sat(lower: 0, upper: 1).toDouble(),
        )
        .toColor();
  }
}

extension Saturation on num {
  /// Saturate the number between given [lower] and [upper] bounds, if provided.
  num sat({num lower, num upper}) {
    return min(upper ?? double.infinity, max(lower ?? -double.infinity, this));
  }
}

class Quantity {
  final int _value;
  final UnitData _unitData;
  Quantity(this._value, this._unitData);

  @override
  String toString() {
    if (_value == 1) {
      return '${_unitData.article}${_unitData.singular}';
    } else {
      return '$_value ${_unitData.plural}';
    }
  }
}

class UnitData {
  final String singular;
  final String plural;
  final String article;

  const UnitData({
    @required this.singular,
    @required this.plural,
    @required this.article,
  });
}

extension DurationToHuman on Duration {
  String toHuman(
      {DurationPrecisionData maximumPrecision = DurationPrecision.minute}) {
    final precisionSequence = [
      DurationPrecision.second,
      DurationPrecision.minute,
      DurationPrecision.hour,
      DurationPrecision.day
    ];

    final availablePrecisions = precisionSequence
        .where((element) => element.duration >= maximumPrecision.duration);

    final precision = availablePrecisions.lastWhere(
      (element) => this > element.duration,
      orElse: () => availablePrecisions.first,
    );

    final units =
        (this.inMilliseconds / precision.duration.inMilliseconds).floor();
    if (units < 1) {
      return 'meno di ${Quantity(1, precision.unitData)} fa';
    } else {
      return '${Quantity(units, precision.unitData)} fa';
    }
  }
}

class DurationPrecisionData {
  final Duration duration;
  final UnitData unitData;

  const DurationPrecisionData({
    @required this.duration,
    @required this.unitData,
  });
}

class DurationPrecision {
  static const second = DurationPrecisionData(
    duration: Duration(milliseconds: 1000),
    unitData: UnitData(singular: 'secondo', plural: 'secondi', article: 'un '),
  );
  static const minute = DurationPrecisionData(
    duration: Duration(minutes: 1),
    unitData: UnitData(singular: 'minuto', plural: 'minuti', article: 'un '),
  );
  static const hour = DurationPrecisionData(
    duration: Duration(hours: 1),
    unitData: UnitData(singular: 'ora', plural: 'ore', article: 'un\''),
  );
  static const day = DurationPrecisionData(
    duration: Duration(days: 1),
    unitData: UnitData(singular: 'giorno', plural: 'giorni', article: 'un '),
  );
  static const week = DurationPrecisionData(
    duration: Duration(days: 7),
    unitData:
        UnitData(singular: 'settimana', plural: 'settimane', article: 'una '),
  );
}

enum Gender { male, female }

extension DateToHuman on DateTime {
  String toHumanString(
      {DurationPrecisionData maximumPrecision = DurationPrecision.minute,
      Duration maximumDuration}) {
    final now = DateTime.now();
    final elapsed = now.difference(this);

    if (maximumDuration == null) {
      maximumDuration = Duration(days: 7);
    }

    if (elapsed <= maximumDuration) {
      return elapsed.toHuman();
    } else {
      return this.toLocaleString();
    }
  }

  String toLocaleString() {
    final months = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre'
    ];
    return '$day ${months[month - 1]} $year';
  }
}
