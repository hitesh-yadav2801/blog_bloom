import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
      borderSide: BorderSide(
          color: color,
          width: 3
      ),
      borderRadius: BorderRadius.circular(10)
  );
  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPalette.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundColor,
    ),
    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(AppPalette.backgroundColor),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: _border(),
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(),
      focusedBorder: _border(AppPalette.gradient2),
      errorBorder: _border(AppPalette.errorColor),
    )
  );
}