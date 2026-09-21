import 'package:flutter/material.dart';

ThemeData clinicTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF147D92), brightness: brightness);
  return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), filled: true),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0));
}
