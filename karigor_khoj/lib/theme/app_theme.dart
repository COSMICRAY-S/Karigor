import 'package:flutter/material.dart';

class AppColors {
  static const Color terracotta = Color(0xFFC1502E);
  static const Color terracottaDark = Color(0xFF9A3D22);
  static const Color brass = Color(0xFFC89B3C);
  static const Color brassDark = Color(0xFFA87B27);
  static const Color clayBg = Color(0xFFFBF3E7);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2B2420);
  static const Color inkSoft = Color(0xFF6B5F53);
  static const Color line = Color(0xFFE8DCC8);
  static const Color slate = Color(0xFF3E5C55);
  static const Color slateDark = Color(0xFF2A4740);
  static const Color slateDarker = Color(0xFF1F3832);
  static const Color slateLight = Color(0xFF6E8C82);
  static const Color success = Color(0xFF3E7A4C);
  static const Color danger = Color(0xFFB4432E);
  static const Color sageBg = Color(0xFFEDF3F1);
  static const Color offline = Color(0xFFB7ADA0);

  // Gradients
  static const LinearGradient terracottaGradient = LinearGradient(
    colors: [terracotta, terracottaDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brassGradient = LinearGradient(
    colors: [brass, brassDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient slateGradient = LinearGradient(
    colors: [slate, slateDark, slateDarker],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roleScreenGradient = LinearGradient(
    colors: [slate, Color(0xFF2A4740), Color(0xFF1F3832)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient slateLightGradient = LinearGradient(
    colors: [slate, slateLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.clayBg,
      primaryColor: AppColors.terracotta,
      colorScheme: ColorScheme.light(
        primary: AppColors.terracotta,
        onPrimary: Colors.white,
        secondary: AppColors.brass,
        onSecondary: Colors.white,
        surface: AppColors.panel,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      fontFamily: 'Hind Siliguri',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Hind Siliguri',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          elevation: 2,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hind Siliguri',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hind Siliguri',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.clayBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.inkSoft, fontSize: 13.5),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get liftShadow => [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.16),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];
}
