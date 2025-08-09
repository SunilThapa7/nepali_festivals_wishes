import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color primaryDark = Color(0xFF9A0007);

  // Accent Colors
  static const Color accent = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF60AD5E);
  static const Color accentDark = Color(0xFF005005);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Festival Category Colors
  static const Color religious = Color(0xFF9C27B0);
  static const Color national = Color(0xFF1976D2);
  static const Color cultural = Color(0xFF009688);
  static const Color seasonal = Color(0xFFEF6C00);

  // Get color based on festival category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'religious':
        return religious;
      case 'national':
        return national;
      case 'cultural':
        return cultural;
      case 'seasonal':
        return seasonal;
      default:
        return primary;
    }
  }

  // Generate a gradient based on a base color
  static List<Color> generateGradient(Color baseColor) {
    final HSLColor hslColor = HSLColor.fromColor(baseColor);

    return [
      baseColor,
      hslColor
          .withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0))
          .toColor(),
    ];
  }

  // Create a MaterialColor from a single Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff, g = (color.g * 255.0).round() & 0xff, b = (color.b * 255.0).round() & 0xff;

    for (int i = 0; i < 10; i++) {
      swatch[(strengths[i] * 1000).round()] = Color.fromRGBO(
        r + ((255 - r) * strengths[i]).round(),
        g + ((255 - g) * strengths[i]).round(),
        b + ((255 - b) * strengths[i]).round(),
        1,
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }
}
