import 'package:flutter/material.dart';

const ink = Color(0xFF1F1B16), paper = Color(0xFFFAF6EE), card = Color(0xFFFFFDF8);
const green = Color(0xFF2E7D4F), red = Color(0xFFC0392B), accent = Color(0xFF5B4BDB);
const sun = Color(0xFFFFD23F), pink = Color(0xFFFF8FB1), mint = Color(0xFFB8F0D0), sky = Color(0xFFB9E3FF);
const mono = 'monospace';

/// Every screen pops in with a little bounce instead of a boring slide.
class PopTransitions extends PageTransitionsBuilder {
  const PopTransitions();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: .9, end: 1).animate(curved),
        child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero).animate(curved), child: child),
      ),
    );
  }
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, surface: paper),
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(backgroundColor: paper, elevation: 0, scrolledUnderElevation: 0, foregroundColor: ink, titleTextStyle: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w800)),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PopTransitions(),
        TargetPlatform.iOS: PopTransitions(),
        TargetPlatform.windows: PopTransitions(),
        TargetPlatform.macOS: PopTransitions(),
        TargetPlatform.linux: PopTransitions(),
      }),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: sun,
        checkmarkColor: ink,
        shape: const StadiumBorder(),
        side: const BorderSide(color: ink, width: 2),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: ink),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

InputDecoration fieldStyle(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ink, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ink, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: accent, width: 3)),
    );

ButtonStyle bigButton([Color c = ink]) => FilledButton.styleFrom(
      backgroundColor: c,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 54),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: ink, width: 2.5)),
    );