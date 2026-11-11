import 'package:flutter/material.dart';

/// Two-colour brand system: forest green + amber.
///
/// Every semantic colour below maps into those two families (plus a neutral
/// slate-green), so the app stays calm and professional. Red is reserved for
/// real errors and declined/rejected states.
class AppColors {
  AppColors._();

  // Green
  static const primary = Color(0xFF1B5E40);
  static const primaryDeep = Color(0xFF0E3B28);
  static const primaryBright = Color(0xFF2F7A55);
  static const primaryMid = Color(0xFF3F7A5E);
  static const mint = Color(0xFFA3D4B8);

  // Amber
  static const amber = Color(0xFFE9A23B);
  static const amberDeep = Color(0xFFB7791F);

  // Neutral
  static const slate = Color(0xFF4F6F62);

  // Semantic aliases (kept so screens read naturally).
  static const success = primaryBright;
  static const warning = amber;
  static const danger = Color(0xFFB3261E);
  static const coral = amberDeep;
  static const info = slate;
  static const violet = primaryMid;

  static const lightBg = Color(0xFFF3F6F3);
  static const darkBg = Color(0xFF0D1410);
  static const darkSurface = Color(0xFF152019);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primary, primaryBright],
  );

  static const amberGradient = LinearGradient(colors: [amberDeep, amber]);

  /// Amber/yellow tones (bronze, amber, gold, sunflower) for the home quick actions.
  static const amberShades = [
    [Color(0xFF7A4E0C), Color(0xFFA8701A)],
    [Color(0xFFA8701A), Color(0xFFD6922B)],
    [Color(0xFFC98A1B), Color(0xFFEBB03F)],
    [Color(0xFFD9A21E), Color(0xFFF5C451)],
  ];

  /// Distinct green tones (forest, emerald, sage, leaf) for icon tiles.
  static const greenShades = [
    [Color(0xFF0E3B28), Color(0xFF1B5E40)],
    [Color(0xFF1B5E40), Color(0xFF2F8A5F)],
    [Color(0xFF3F6B4F), Color(0xFF6E9A72)],
    [Color(0xFF4A6B2A), Color(0xFF7FA34A)],
  ];

  /// Stable palette for avatars and accents, picked by hashing a string.
  static const palette = [primary, primaryBright, amberDeep, slate, primaryMid, Color(0xFF8C6A1E)];

  static Color fromString(String seed) => palette[seed.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length];

  /// Green-only gradients for project / feature cards, picked by hashing a string.
  static const cardGradients = [
    [Color(0xFF0E3B28), Color(0xFF1B5E40)],
    [Color(0xFF143F2D), Color(0xFF2F7A55)],
    [Color(0xFF0B3022), Color(0xFF3F7A5E)],
  ];

  static LinearGradient gradientFor(String seed) {
    final c = cardGradients[seed.codeUnits.fold<int>(0, (a, b) => a + b) % cardGradients.length];
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: c);
  }
}
