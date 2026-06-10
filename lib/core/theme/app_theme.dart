import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // Brand seed — a calm sky blue works better than deep purple for a weather app
  static const Color _seed = Color(0xFF1565C0);

  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return _base(cs).copyWith(
      appBarTheme: _appBar(cs, Brightness.light),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _base(cs).copyWith(
      appBarTheme: _appBar(cs, Brightness.dark),
    );
  }

  // ── Shared base ────────────────────────────────────────────────────────────
  static ThemeData _base(ColorScheme cs) => ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHighest,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  static AppBarTheme _appBar(ColorScheme cs, Brightness brightness) =>
      AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        )
            : SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      );
}