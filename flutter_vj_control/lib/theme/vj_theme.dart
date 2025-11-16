import 'package:flutter/material.dart';

/// VJ Theme
/// Dark theme optimized for VJ performance with cyberpunk aesthetics
class VJTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FFFF), // Cyan
        primaryContainer: Color(0xFF004D4D),
        secondary: Color(0xFFFF00FF), // Magenta
        secondaryContainer: Color(0xFF4D004D),
        tertiary: Color(0xFFFFAA00), // Orange
        tertiaryContainer: Color(0xFF4D3300),
        surface: Color(0xFF0A0A0A),
        surfaceContainerHighest: Color(0xFF1A1A1A),
        background: Color(0xFF000000),
        error: Color(0xFFFF4444),
        onPrimary: Color(0xFF000000),
        onSecondary: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        onBackground: Color(0xFFFFFFFF),
        onError: Color(0xFF000000),
        outline: Color(0xFF00FFFF),
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00FFFF),
          fontFamily: 'Orbitron',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00FFFF),
          fontFamily: 'Orbitron',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00FFFF),
          fontFamily: 'Orbitron',
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFCCCCCC),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFCCCCCC),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF999999),
        ),
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Color(0xFF00FFFF),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00FFFF),
          fontFamily: 'Orbitron',
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        selectedItemColor: Color(0xFF00FFFF),
        unselectedItemColor: Color(0xFF666666),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFFF),
          foregroundColor: const Color(0xFF000000),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF00FFFF),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: const Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF00FFFF),
            width: 1,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FFFF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FFFF),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FFFF),
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF00FFFF),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF666666),
        ),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF00FFFF),
        inactiveTrackColor: Color(0xFF333333),
        thumbColor: Color(0xFF00FFFF),
        overlayColor: Color(0x3300FFFF),
        valueIndicatorColor: Color(0xFF00FFFF),
        valueIndicatorTextStyle: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00FFFF);
          }
          return const Color(0xFF666666);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00FFFF).withOpacity(0.5);
          }
          return const Color(0xFF333333);
        }),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF00FFFF),
        thickness: 1,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF000000),
    );
  }
}
