import 'dart:math';

import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
  num sat({num? lower, num? upper}) {
    return min(upper ?? double.infinity, max(lower ?? -double.infinity, this));
  }
}

extension DurationToHuman on Duration {
  String toHuman({required BuildContext context}) {
    final Map<Duration, String Function(int)> precisionSequence = {
      Duration(minutes: 1): AppLocalizations.of(context)!.minute,
      Duration(hours: 1): AppLocalizations.of(context)!.hour,
      Duration(days: 1): AppLocalizations.of(context)!.day,
      Duration(days: 7): AppLocalizations.of(context)!.week,
    };

    final availablePrecisions = precisionSequence.entries
        .where((element) => element.key >= precisionSequence.entries.first.key);

    final precision = availablePrecisions.lastWhere(
      (element) => this > element.key,
      orElse: () => availablePrecisions.first,
    );

    final units = (this.inMilliseconds / precision.key.inMilliseconds).floor();
    return precision.value(units);
  }
}

extension DateToHuman on DateTime {
  String toHumanString(
      {required BuildContext context, Duration? maximumDuration}) {
    final now = DateTime.now();
    final elapsed = now.difference(this);

    if (maximumDuration == null) {
      maximumDuration = Duration(days: 7);
    }

    if (elapsed.inMilliseconds > 0 && elapsed <= maximumDuration) {
      return elapsed.toHuman(context: context);
    } else {
      return DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName)
              .format(this) +
          ' ' +
          TimeOfDay.fromDateTime(this).format(context);
    }
  }

  DateTime asStrictlyPast() =>
      this.isBefore(DateTime.now()) ? this : DateTime.now();

  DateTime asStrictlyFuture() =>
      this.isAfter(DateTime.now()) ? this : DateTime.now();
}
