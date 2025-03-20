import 'package:flutter/material.dart';

/// Brand colors used throughout the app
class BrandColors {
  BrandColors._(); // Private constructor to prevent instantiation

  /// Gold color (#d2982a)
  static const Color gold = Color(0xFFD2982A);

  /// Dark gray color (#2d2c31)
  static const Color darkGray = Color(0xFF2D2C31);

  /// Create a color from a hex string
  static Color fromHex(String hexString) {
    final hexString2 = hexString.toUpperCase().replaceAll('#', '');
    if (hexString2.length == 6) {
      return Color(int.parse('FF$hexString2', radix: 16));
    } else if (hexString2.length == 8) {
      return Color(int.parse(hexString2, radix: 16));
    }
    throw ArgumentError('Invalid hex color format: $hexString');
  }
}

/// Extension on Color for hex string conversion
extension ColorExtension on Color {
  /// Convert a color to a hex string
  String toHex({bool includeHashSign = true, bool includeAlpha = false}) {
    String hex = '';
    if (includeHashSign) hex += '#';

    if (includeAlpha) {
      hex += alpha.toRadixString(16).padLeft(2, '0');
    }

    hex += red.toRadixString(16).padLeft(2, '0');
    hex += green.toRadixString(16).padLeft(2, '0');
    hex += blue.toRadixString(16).padLeft(2, '0');

    return hex.toUpperCase();
  }
}
