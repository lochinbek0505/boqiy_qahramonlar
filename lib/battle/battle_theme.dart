import 'package:flutter/material.dart';

/// Jang ekranlari (war_startegy) o'z rang va shriftlari bilan chizilgan —
/// xarita, HUD va panellar shu yorug' "pergament" mavzusiga moslangan,
/// shuning uchun ilova qora rejimda bo'lsa ham ular shu mavzu ichida ochiladi.
final ThemeData battleTheme = ThemeData(
  fontFamily: 'RobotoCondensed',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontFamily: 'PTSerif', fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontFamily: 'PTSerif', fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontFamily: 'PTSerif', fontWeight: FontWeight.w700),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6D4C2F),
    surface: const Color(0xFFF7F3EA),
  ),
  scaffoldBackgroundColor: const Color(0xFFF7F3EA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2B2118),
    foregroundColor: Color(0xFFF3E6CC),
    titleTextStyle: TextStyle(fontFamily: 'PTSerif', fontSize: 19, color: Color(0xFFF3E6CC)),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      side: BorderSide(color: Color(0xFFE2D8C4)),
    ),
  ),
);
