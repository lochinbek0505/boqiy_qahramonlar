import 'package:flutter/material.dart';

/// Brend rangi sifatida ikkala mavzuda (light/dark) ham deyarli
/// o'zgarmaydigan ranglar (aksentlar, tugmalar). Fon, matn va karta
/// ranglari esa mavzuga (theme) qarab moslashishi kerak — ular uchun
/// [AppPalette] dan foydalaning (context.palette).
class AppColors {
  static const background = Color(0xFFFCF6EE);
  static const appbar = Color(0xffFDFCF6);

  static const brown = Color(0xffD59349);
  static const black = Color(0xff000000);
  static const midnightBlue = Color(0xff0E375D);
  static const steelBlue = Color(0xff325171);
  static const darkBlue = Color(0xff002E56);
  static const indigoBlue = Color(0xff2B4886);

  static const gray = Color(0xffB6BDC8);
}

/// Qora (dark) tema qo'shilganda sahifa foni, appbar/karta foni va
/// matn ranglari kontekstga (yorug'lik rejimiga) qarab almashishi
/// uchun ishlatiladigan semantik ranglar to'plami.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color appbarBg;
  final Color cardBg;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color placeholder;
  final Color accent;
  // Sarlavha rangi (person/poem kartalari, sahifa sarlavhalari). Ilgari
  // ko'k (headingBlue) edi — endi brend jigarrangiga mos, issiq to'q
  // bordo (maroon) tusga almashtirildi.
  final Color heading;

  const AppPalette({
    required this.background,
    required this.appbarBg,
    required this.cardBg,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.placeholder,
    required this.accent,
    required this.heading,
  });

  static const light = AppPalette(
    background: Color(0xFFFCF6EE),
    appbarBg: Color(0xFFFDFCF6),
    cardBg: Colors.white,
    divider: Color(0xFFE3E1DC),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    placeholder: Color(0xFFECEFF1),
    accent: Color(0xffD59349),
    heading: Color(0xFF7A3B2E),
  );

  static const dark = AppPalette(
    background: Color(0xFF121212),
    appbarBg: Color(0xFF1E1E1E),
    cardBg: Color(0xFF232323),
    divider: Color(0xFF3A3D42),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB0B3B8),
    textMuted: Color(0xFF8A8D91),
    placeholder: Color(0xFF2C2C2C),
    accent: Color(0xffE0A85F),
    heading: Color(0xFFEFEFEF),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? appbarBg,
    Color? cardBg,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? placeholder,
    Color? accent,
    Color? heading,
  }) {
    return AppPalette(
      background: background ?? this.background,
      appbarBg: appbarBg ?? this.appbarBg,
      cardBg: cardBg ?? this.cardBg,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      placeholder: placeholder ?? this.placeholder,
      accent: accent ?? this.accent,
      heading: heading ?? this.heading,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      appbarBg: Color.lerp(appbarBg, other.appbarBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}