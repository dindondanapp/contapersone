import 'package:flutter/material.dart';

extension ColorToMaterialColor on Color {
  MaterialColor toMaterialColor() {
    final base = HSLColor.fromColor(this);

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
        lightnessMap.map<int, Color>((key, multiplier) => MapEntry(
            key, base.withLightness(base.lightness * multiplier).toColor())));
  }
}
