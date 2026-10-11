import 'package:flutter/material.dart';

const ink = Color(0xFF1F1B16), paper = Color(0xFFFAF6EE), card = Color(0xFFFFFDF8);
const green = Color(0xFF2E7D4F), red = Color(0xFFC0392B), accent = Color(0xFF5B4BDB);
const mono = 'monospace';

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, surface: paper),
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(backgroundColor: paper, elevation: 0, scrolledUnderElevation: 0, foregroundColor: ink),
    );

InputDecoration fieldStyle(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );

ButtonStyle bigButton([Color c = ink]) => FilledButton.styleFrom(
      backgroundColor: c,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );