import "package:flutter/material.dart";

ThemeData buildTheme() {
  const seed = Color(0xFF6C63FF);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFF7F9FC),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    useMaterial3: true,
  );
}
