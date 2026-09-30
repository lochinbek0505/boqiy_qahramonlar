import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.light.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(backgroundColor: AppPalette.light.appbarBg),
    extensions: const [AppPalette.light],
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.dark.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(backgroundColor: AppPalette.dark.appbarBg),
    extensions: const [AppPalette.dark],
  );
}
