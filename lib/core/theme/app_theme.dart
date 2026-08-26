import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static const Color crimson = Color(0xFFB4232D);
  static const Color coral = Color(0xFFE33D45);
  static const Color orange = Color(0xFFF28C28);
  static const Color blush = Color(0xFFFFF1F0);
  static const Color warmWhite = Color(0xFFFFFBF8);
  static const Color charcoal = Color(0xFF2B2525);

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: crimson,
          brightness: Brightness.light,
        ).copyWith(
          primary: crimson,
          onPrimary: Colors.white,
          primaryContainer: blush,
          onPrimaryContainer: const Color(0xFF74131B),
          secondary: orange,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFE2C2),
          onSecondaryContainer: const Color(0xFF6B3900),
          surface: Colors.white,
          onSurface: charcoal,
          error: const Color(0xFFBA1A1A),
          outline: const Color(0xFFD6C3C1),
          outlineVariant: const Color(0xFFF0DEDC),
        );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE6D2D0)),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: warmWhite,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: charcoal,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: charcoal,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(color: charcoal, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: charcoal, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: charcoal, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: charcoal, height: 1.4),
        bodyMedium: TextStyle(color: charcoal, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: warmWhite,
        foregroundColor: charcoal,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(color: Color(0xFF756765)),
        prefixIconColor: crimson,
        suffixIconColor: crimson,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: crimson, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: crimson,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE1C3C5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: roundedShape,
          elevation: 2,
          shadowColor: crimson.withValues(alpha: 0.28),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: crimson,
          side: const BorderSide(color: Color(0xFFE0A9AD)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: roundedShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: crimson),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: crimson.withValues(alpha: 0.08),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: roundedShape.copyWith(
          side: const BorderSide(color: Color(0xFFF2E3E1)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: crimson,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: blush,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? crimson : charcoal,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? crimson : charcoal,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: crimson),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: charcoal,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFF1DFDD)),
    );
  }
}
