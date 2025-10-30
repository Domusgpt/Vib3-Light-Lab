/// VIB3 Light Lab - Vaporwave Holographic Theme
///
/// Complete Material theme implementing the vaporwave holographic aesthetic
/// with glassmorphic containers, neon accents, and cyberpunk styling.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';

/// VIB3 Color Palette - Vaporwave Holographic
class VIB3Colors {
  // Primary Colors
  static const Color cyan = Color(0xFF00FFFF);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color purple = Color(0xFF9D00FF);
  static const Color pink = Color(0xFFFF0099);

  // Background Colors
  static const Color deepPurple = Color(0xFF2D033B);
  static const Color darkNavy = Color(0xFF0A0E27);
  static const Color darkPurple = Color(0xFF1A0B2E);

  // Accent Colors
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color electricBlue = Color(0xFF0080FF);

  // UI Colors
  static const Color glassBorder = Color(0x44FF00FF);
  static const Color glassBackground = Color(0x22FF00FF);
  static const Color shadowGlow = Color(0x44FF00FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textDisabled = Color(0xFF666666);

  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF0055);

  // Gradient Pairs
  static const List<Color> primaryGradient = [cyan, magenta];
  static const List<Color> secondaryGradient = [purple, pink];
  static const List<Color> backgroundGradient = [darkNavy, deepPurple];
}

/// VIB3 Text Styles - Orbitron Font with Glow Effects
class VIB3TextStyles {
  // Heading Styles
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: VIB3Colors.textPrimary,
    shadows: [
      Shadow(
        color: VIB3Colors.magenta,
        blurRadius: 10,
      ),
    ],
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: VIB3Colors.textPrimary,
    shadows: [
      Shadow(
        color: VIB3Colors.cyan,
        blurRadius: 8,
      ),
    ],
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: VIB3Colors.textPrimary,
  );

  // Body Styles
  static const TextStyle body1 = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: VIB3Colors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: VIB3Colors.textSecondary,
  );

  // Label Styles
  static const TextStyle label = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: VIB3Colors.textSecondary,
    textBaseline: TextBaseline.alphabetic,
  );

  // Parameter Value Style
  static const TextStyle parameterValue = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: VIB3Colors.cyan,
    shadows: [
      Shadow(
        color: VIB3Colors.cyan,
        blurRadius: 6,
      ),
    ],
  );

  // System Button Style
  static const TextStyle systemButton = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: VIB3Colors.textPrimary,
  );
}

/// VIB3 Theme Data
class VIB3Theme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: VIB3Colors.magenta,
        secondary: VIB3Colors.cyan,
        surface: VIB3Colors.darkNavy,
        error: VIB3Colors.error,
        onPrimary: VIB3Colors.textPrimary,
        onSecondary: VIB3Colors.textPrimary,
        onSurface: VIB3Colors.textPrimary,
        onError: VIB3Colors.textPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: VIB3Colors.darkNavy,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: VIB3Colors.darkPurple,
        foregroundColor: VIB3Colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: VIB3TextStyles.h2,
      ),

      // Card
      cardTheme: CardTheme(
        color: VIB3Colors.glassBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: VIB3Colors.glassBorder,
            width: 2,
          ),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VIB3Colors.glassBackground,
          foregroundColor: VIB3Colors.magenta,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: VIB3Colors.magenta,
              width: 2,
            ),
          ),
          textStyle: VIB3TextStyles.systemButton,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VIB3Colors.cyan,
          side: const BorderSide(
            color: VIB3Colors.cyan,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: VIB3TextStyles.systemButton,
        ),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: VIB3Colors.magenta,
        inactiveTrackColor: VIB3Colors.glassBorder,
        thumbColor: VIB3Colors.cyan,
        overlayColor: VIB3Colors.cyan.withOpacity(0.3),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8,
          elevation: 4,
          pressedElevation: 6,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VIB3Colors.cyan;
          }
          return VIB3Colors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VIB3Colors.magenta.withOpacity(0.5);
          }
          return VIB3Colors.glassBorder;
        }),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: VIB3TextStyles.h1,
        displayMedium: VIB3TextStyles.h2,
        displaySmall: VIB3TextStyles.h3,
        bodyLarge: VIB3TextStyles.body1,
        bodyMedium: VIB3TextStyles.body2,
        labelLarge: VIB3TextStyles.label,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: VIB3Colors.cyan,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: VIB3Colors.glassBorder,
        thickness: 1,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: VIB3Colors.darkPurple,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: VIB3Colors.cyan,
            width: 1,
          ),
        ),
        textStyle: VIB3TextStyles.body2,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VIB3Colors.glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VIB3Colors.glassBorder,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VIB3Colors.glassBorder,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VIB3Colors.cyan,
            width: 2,
          ),
        ),
        labelStyle: VIB3TextStyles.label,
        hintStyle: VIB3TextStyles.body2.copyWith(
          color: VIB3Colors.textDisabled,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: VIB3Colors.darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: VIB3Colors.magenta,
            width: 2,
          ),
        ),
        titleTextStyle: VIB3TextStyles.h2,
        contentTextStyle: VIB3TextStyles.body1,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VIB3Colors.darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),
    );
  }

  /// Glassmorphic Container Decoration
  static BoxDecoration glassContainer({
    Color? borderColor,
    double borderWidth = 2,
    double borderRadius = 16,
    List<Color>? gradientColors,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.15)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [
                VIB3Colors.glassBackground,
                Color(0x1100FFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? VIB3Colors.glassBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? VIB3Colors.magenta).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Holographic Text Gradient
  static ShaderMask holographicText({
    required Widget child,
    List<Color>? gradientColors,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors ?? VIB3Colors.primaryGradient,
          stops: const [0.0, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  /// Animated Glow Effect
  static List<BoxShadow> glowEffect({
    required Color color,
    double blurRadius = 20,
    double spreadRadius = 2,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: blurRadius * 1.5,
        spreadRadius: spreadRadius * 1.5,
      ),
    ];
  }
}

/// Animation Durations
class VIB3Animations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
}

/// Layout Constants
class VIB3Layout {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  static const double panelWidth = 400.0;
  static const double panelMinWidth = 300.0;
  static const double panelMaxWidth = 600.0;
}
