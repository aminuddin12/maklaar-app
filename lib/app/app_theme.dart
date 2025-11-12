import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// Enum representing the available app themes
enum AppTheme {
  /// Light theme mode
  light,

  /// Dark theme mode
  dark,
}

/// Common theme properties used across both light and dark themes
class _CommonThemeProperties {
  static const String fontFamily = "Manrope";
  static const bool useMaterial3 = true;
}

/// Theme data configuration for the application
final appThemeData = {
  AppTheme.light: ThemeData(
    brightness: Brightness.light,
    useMaterial3: _CommonThemeProperties.useMaterial3,
    fontFamily: _CommonThemeProperties.fontFamily,

    // Text selection theme configuration
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: territoryColor_,
      cursorColor: territoryColor_,
      selectionHandleColor: territoryColor_,
    ),

    // Switch theme configuration
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(territoryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return territoryColor_.withValues(alpha: 0.3);
        }
        return primaryColorDark;
      }),
    ),

    // Color scheme configuration
    colorScheme: ColorScheme.fromSeed(
      error: errorMessageColor,
      seedColor: territoryColor_,
      brightness: Brightness.light,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColor_,
      foregroundColor: textDarkColor,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  ),
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    useMaterial3: _CommonThemeProperties.useMaterial3,
    fontFamily: _CommonThemeProperties.fontFamily,

    // Text selection theme configuration
    textSelectionTheme: const TextSelectionThemeData(
      selectionHandleColor: territoryColorDark,
      selectionColor: territoryColorDark,
      cursorColor: territoryColorDark,
    ),

    // Color scheme configuration
    colorScheme: ColorScheme.fromSeed(
      error: errorMessageColor.withValues(alpha: 0.7),
      seedColor: territoryColorDark,
      brightness: Brightness.dark,
    ),

    // Switch theme configuration
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(territoryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return territoryColor_.withValues(alpha: 0.3);
        }
        return primaryColor_.withValues(alpha: 0.2);
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColorDark,
      foregroundColor: textColorDarkTheme,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  ),
};
