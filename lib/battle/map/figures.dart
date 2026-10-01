import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import 'frame.dart';

// ---------------------------------------------------------------------------
// Figuralar soni va saf shakli
// ---------------------------------------------------------------------------

/// Bo'linma nechta figura bilan chiziladi. Oddiy qo'shinlarda son askarlar soniga
/// to'g'ri proporsional — katta qo'shin xaritada ham katta ko'rinadi.
int figureCount(Unit u, Battle b) {
  final t = u.type;
  if (t.formation == Formation.single) return 1;
  if (t.glyph == Glyph.elephant) return (u.count / 4).round().clamp(3, 10);
  if (t.isAirborne) return u.countsAsSoldiers ? 5 : (u.count / 60).round().clamp(3, 7);
  if (t.domain == Domain.sea) return u.countsAsSoldiers ? 4 : u.count.clamp(2, 8);
  final max = math.max(1, b.maxCount);
  final c = u.countsAsSoldiers ? u.count : math.min(u.count, max);
  final n = (44 * c / max).round();
  return switch (t.formation) {
    Formation.battery => n.clamp(3, 12),
    Formation.fortLine => n.clamp(5, 16),
    Formation.column => n.clamp(4, 16),
    _ => n.clamp(4, 44),
  };
}

final _layoutCache = <String, List<Offset>>{};

/// Saf shakli: x — oldinga (dushman tomon), y — yon tomon. Birlik — figuralar oralig'i.
/// Ro'yxat oldingi figuralardan boshlanadi: talafot ko'rilganda orqadagilar yo'qoladi.
List<Offset> formationLayout(Formation f, int n) {
  return _layoutCache.putIfAbsent('${f.index}_$n', () {
    final out = <Offset>[];
    void grid(int ranks, double dx, double dy, {double stagger = 0}) {
      final files = (n / ranks).ceil();
      for (var i = 0; i < n; i++) {
        final r = i ~/ files, c = i % files;
        out.add(Offset(-r * dx + (ranks - 1) * dx / 2, (c - (files - 1) / 2) * dy + (r.isOdd ? stagger : 0)));
      }
    }

    switch (f) {
      case Formation.block:
        grid(math.max(2, math.sqrt(n / 3).round()), 0.9, 0.9);
      case Formation.phalanx:
        grid(math.max(3, math.sqrt(n / 1.6).round()), 0.75, 0.8);
      case Formation.line:
        grid(n > 24 ? 3 : 2, 0.8, 0.95, stagger: 0.45);
      case Formation.column:
        grid((n / 2).ceil(), 0.95, 0.9);
      case Formation.fortLine:
        for (var i = 0; i < n; i++) {
          out.add(Offset((i.isEven ? 0.15 : -0.15), (i - (n - 1) / 2) * 1.0));
        }
      case Formation.wedge:
        var row = 0, placed = 0;
        while (placed < n) {
          final inRow = 2 * row + 1;
          for (var j = 0; j < inRow && placed < n; j++, placed++) {
            out.add(Offset(-row * 0.85, (j - row) * 0.75));
          }
          row++;
        }
        final depth = (row - 1) * 0.85;
        for (var i = 0; i < out.length; i++) {
          out[i] = out[i] + Offset(depth / 2, 0);
        }
      case Formation.swarm:
        for (var i = 0; i < n; i++) {
          final r = math.sqrt(i + 0.5) * 0.62;
          final a = i * 2.39996;
          out.add(Offset(math.cos(a) * r * 0.7, math.sin(a) * r * 1.35));
        }
      case Formation.cluster:
        // 4 kishilik guruhlar, guruhlar orasida bo'sh joy.
        final groups = (n / 4).ceil();
        final cols = math.max(1, math.sqrt(groups * 2).round());
        for (var i = 0; i < n; i++) {
          final g = i ~/ 4, m = i % 4;
          final gr = g ~/ cols, gc = g % cols;
          out.add(Offset(-gr * 1.9 + (m ~/ 2) * -0.55, (gc - (cols - 1) / 2) * 2.1 + (m % 2) * 0.55 - 0.27));
        }
      case Formation.battery:
        final rows = n > 8 ? 2 : 1;
        final perRow = (n / rows).ceil();
        for (var i = 0; i < n; i++) {
          final r = i ~/ perRow, c = i % perRow;
          out.add(Offset(-r * 0.8 + (rows - 1) * 0.4, (c - (perRow - 1) / 2) * 0.75 + r * 0.35));
        }
      case Formation.vee:
        out.add(Offset.zero);
        for (var i = 1; i < n; i++) {
          final k = (i + 1) ~/ 2;
          out.add(Offset(-k * 0.55, (i.isOdd ? 1 : -1) * k * 0.6));
        }
      case Formation.single:
        out.add(Offset.zero);
    }
    return out;
  });
}

/// Saf radiusi (piksel) — belgilar va tanlash halqasi uchun.
double formationRadius(UnitType type, int n, double fig) {
  var r = 0.0;
  for (final o in formationLayout(type.formation, n)) {
    r = math.max(r, o.distance);
  }
  return (r * type.figureSpacing + 1.2) * fig;
}

// ---------------------------------------------------------------------------
// Figuralar. Kanvas figura markaziga ko'chirilgan, x o'qi oldinga qaragan.
// ---------------------------------------------------------------------------

const _horseColors = [Color(0xFF5B4636), Color(0xFF3A2E26), Color(0xFF7A5A3C), Color(0xFF6E6259)];
const _wood = Color(0xFF6B4E2A);
const _metal = Color(0xFF4A4D45);
const _ink = Color(0xFF2A2118);

Color _darken(Color c, double t) => Color.lerp(c, Colors.black, t)!;
Color _lighten(Color c, double t) => Color.lerp(c, Colors.white, t)!;

class _P {
  _P(this.alpha);
  final double alpha;
  Paint fill(Color c) => Paint()..color = c.withValues(alpha: c.a * alpha);
  Paint line(Color c, double w) => Paint()
    ..color = c.withValues(alpha: c.a * alpha)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;
}

/// Bitta figurani chizadi.
///  * [charging] — otliq zarba beryapti: nayzalar oldinga tushiriladi;
///  * [time] — ichki animatsiyalar (vertolyot parragi, bayroq, katapulta richagi).
void drawGlyph(Canvas canvas, Glyph g, double f, Color color,
    {int seed = 0,
    double time = 0,
    double alpha = 1,
    bool charging = false,
    double motion = 0,
    bool royal = false,
    bool modern = false,
    double heading = 0}) {
  final p = _P(alpha);
  final outline = _darken(color, 0.45);

  void body(double r, [Color? c]) {
    canvas.drawCircle(Offset.zero, f * r, p.fill(c ?? color));
    canvas.drawCircle(Offset.zero, f * r, p.line(outline, f * 0.11));
  }

  switch (g) {
    case Glyph.footman:
      canvas.drawLine(Offset(0, f * 0.3), Offset(f * 0.75, f * 0.3), p.line(_metal, f * 0.12));
      body(0.44);
      canvas.drawCircle(Offset(f * 0.05, -f * 0.05), f * 0.16, p.fill(_lighten(color, 0.5)));
    case Glyph.spearman:
      canvas.drawLine(Offset(-f * 0.2, f * 0.28), Offset(f * 1.3, f * 0.28), p.line(const Color(0xFF4A3A28), f * 0.11));
      body(0.42);
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: f * 0.5), -1.0, 2.0, false,
          p.line(_lighten(color, 0.35), f * 0.16));
    case Glyph.pikeman:
      canvas.drawLine(Offset(-f * 0.4, f * 0.22), Offset(f * 2.3, f * 0.22), p.line(const Color(0xFF4A3A28), f * 0.1));
      canvas.drawLine(Offset(f * 2.1, f * 0.22), Offset(f * 2.35, f * 0.22), p.line(_metal, f * 0.16));
      body(0.38);
    case Glyph.swordsman:
      canvas.drawLine(Offset(f * 0.1, -f * 0.35), Offset(f * 0.8, -f * 0.35), p.line(const Color(0xFFB8B8B0), f * 0.1));
      body(0.42);
      // Katta qalqon oldinda.
      final shield = RRect.fromRectAndRadius(
          Rect.fromLTWH(f * 0.32, -f * 0.5, f * 0.28, f * 1.0), Radius.circular(f * 0.1));
      canvas.drawRRect(shield, p.fill(_lighten(color, 0.25)));
      canvas.drawRRect(shield, p.line(outline, f * 0.08));
    case Glyph.archer:
      body(0.38);
      canvas.drawArc(Rect.fromCircle(center: Offset(f * 0.1, 0), radius: f * 0.62), -1.15, 2.3, false,
          p.line(const Color(0xFF5A3E22), f * 0.13));
      canvas.drawLine(Offset(f * 0.1 + math.cos(-1.15) * f * 0.62, math.sin(-1.15) * f * 0.62),
          Offset(f * 0.1 + math.cos(1.15) * f * 0.62, math.sin(1.15) * f * 0.62), p.line(const Color(0x99FFFFFF), f * 0.05));
    case Glyph.crossbowman:
      canvas.drawLine(Offset.zero, Offset(f * 0.95, 0), p.line(_wood, f * 0.16));
      canvas.drawLine(Offset(f * 0.75, -f * 0.4), Offset(f * 0.75, f * 0.4), p.line(_metal, f * 0.12));
      body(0.4);
    case Glyph.musketeer:
      canvas.drawLine(Offset(-f * 0.1, f * 0.25), Offset(f * 1.15, f * 0.25), p.line(const Color(0xFF3A2A1A), f * 0.13));
      body(0.42);
      // Kesishgan oq kamarlar va qalpoq.
      canvas.drawLine(Offset(-f * 0.3, -f * 0.3), Offset(f * 0.3, f * 0.3), p.line(const Color(0xDDFFFFFF), f * 0.08));
      canvas.drawLine(Offset(-f * 0.3, f * 0.3), Offset(f * 0.3, -f * 0.3), p.line(const Color(0xDDFFFFFF), f * 0.08));
      canvas.drawCircle(Offset.zero, f * 0.17, p.fill(_ink));
    case Glyph.lightHorse:
    case Glyph.horseArcher:
    case Glyph.heavyHorse:
      final horse = _horseColors[seed % _horseColors.length];
      _drawHorse(canvas, p, f, horse, time: time, motion: motion, seed: seed, heavy: g == Glyph.heavyHorse,
          caparison: g == Glyph.heavyHorse ? color : null);
      _drawRider(canvas, p, f, color,
          kind: switch (g) {
            Glyph.heavyHorse => _RiderKind.knight,
            Glyph.horseArcher => _RiderKind.archer,
            _ => _RiderKind.sabre,
          },
          charging: charging,
          time: time,
          seed: seed);
    case Glyph.camel:
      const tan = Color(0xFFC2A26B);
      _drawHorse(canvas, p, f, tan, time: time, motion: motion, seed: seed, camel: true);
      _drawRider(canvas, p, f, color, kind: _RiderKind.sabre, charging: charging, time: time, seed: seed);
    case Glyph.elephant:
      const grey = Color(0xFF807C78);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: f * 2.6, height: f * 1.7), p.fill(grey));
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 1.2, 0), width: f * 1.0, height: f * 1.1), p.fill(_darken(grey, 0.1)));
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 1.0, -f * 0.6), width: f * 0.7, height: f * 0.5), p.fill(_lighten(grey, 0.15)));
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 1.0, f * 0.6), width: f * 0.7, height: f * 0.5), p.fill(_lighten(grey, 0.15)));
      final trunk = Path()
        ..moveTo(f * 1.6, 0)
        ..quadraticBezierTo(f * 2.2, f * 0.1 * math.sin(time * 3 + seed), f * 2.3, f * 0.45);
      canvas.drawPath(trunk, p.line(_darken(grey, 0.15), f * 0.28));
      canvas.drawLine(Offset(f * 1.55, -f * 0.25), Offset(f * 1.95, -f * 0.4), p.line(const Color(0xFFF1EBDD), f * 0.12));
      canvas.drawLine(Offset(f * 1.55, f * 0.25), Offset(f * 1.95, f * 0.4), p.line(const Color(0xFFF1EBDD), f * 0.12));
      canvas.drawRect(Rect.fromCenter(center: Offset(-f * 0.2, 0), width: f * 0.95, height: f * 0.95), p.fill(color));
      canvas.drawRect(Rect.fromCenter(center: Offset(-f * 0.2, 0), width: f * 0.95, height: f * 0.95),
          p.line(_lighten(color, 0.5), f * 0.1));
    case Glyph.catapult:
      final frame = Rect.fromCenter(center: Offset.zero, width: f * 1.7, height: f * 1.0);
      canvas.drawRect(frame, p.line(_wood, f * 0.18));
      for (final c in [frame.topLeft, frame.topRight, frame.bottomLeft, frame.bottomRight]) {
        canvas.drawCircle(c, f * 0.2, p.fill(const Color(0xFF3B2B1B)));
      }
      final swing = (math.sin(time * 1.3 + seed) + 1) / 2; // richag tebranishi
      final tip = Offset(-f * 0.9 + swing * f * 1.8, 0);
      canvas.drawLine(Offset(-f * 0.1, 0), tip, p.line(const Color(0xFF8A6A42), f * 0.16));
      canvas.drawCircle(tip, f * 0.2, p.fill(const Color(0xFF6E6E68)));
      canvas.drawCircle(Offset(-f * 1.2, -f * 0.35), f * 0.24, p.fill(color));
      canvas.drawCircle(Offset(-f * 1.2, f * 0.35), f * 0.24, p.fill(color));
    case Glyph.cannon:
      canvas.drawLine(Offset(-f * 0.4, 0), Offset(f * 1.2, 0), p.line(const Color(0xFF7A5A2A), f * 0.36));
      canvas.drawLine(Offset(f * 1.05, 0), Offset(f * 1.25, 0), p.line(const Color(0xFF5A3F1A), f * 0.44));
      canvas.drawCircle(Offset(-f * 0.1, -f * 0.45), f * 0.28, p.fill(const Color(0xFF3B2B1B)));
      canvas.drawCircle(Offset(-f * 0.1, f * 0.45), f * 0.28, p.fill(const Color(0xFF3B2B1B)));
      canvas.drawCircle(Offset(-f * 0.95, -f * 0.35), f * 0.26, p.fill(color));
      canvas.drawCircle(Offset(-f * 0.95, f * 0.35), f * 0.26, p.fill(color));
    case Glyph.commander:
      _drawCommander(canvas, p, f, color, time: time, seed: seed, heading: heading, royal: royal, modern: modern);
    case Glyph.rifleman:
      final c = Color.lerp(color, const Color(0xFF55583F), 0.25)!;
      canvas.drawLine(Offset(0, f * 0.22), Offset(f * 0.85, f * 0.22), p.line(const Color(0xFF2E2A22), f * 0.1));
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: f * 0.75, height: f * 0.95), p.fill(c));
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: f * 0.75, height: f * 0.95), p.line(outline, f * 0.1));
      canvas.drawCircle(Offset(f * 0.08, 0), f * 0.22, p.fill(_darken(c, 0.35)));
    case Glyph.apc:
      final hull = Color.lerp(color, const Color(0xFF4B5040), 0.4)!;
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: f * 1.9, height: f * 1.1),
          Radius.circular(f * 0.35));
      canvas.drawRRect(r, p.fill(hull));
      canvas.drawRRect(r, p.line(_darken(hull, 0.45), f * 0.1));
      for (var i = 0; i < 4; i++) {
        final x = -f * 0.7 + i * f * 0.46;
        canvas.drawCircle(Offset(x, -f * 0.62), f * 0.16, p.fill(_ink));
        canvas.drawCircle(Offset(x, f * 0.62), f * 0.16, p.fill(_ink));
      }
      canvas.drawCircle(Offset(f * 0.2, 0), f * 0.25, p.fill(_lighten(hull, 0.15)));
      canvas.drawLine(Offset(f * 0.2, 0), Offset(f * 0.85, 0), p.line(_ink, f * 0.08));
    case Glyph.tank:
      final hull = Color.lerp(color, const Color(0xFF4B5040), 0.35)!;
      final body = Rect.fromCenter(center: Offset.zero, width: f * 1.9, height: f * 1.25);
      canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(f * 0.2)), p.fill(_darken(hull, 0.35)));
      canvas.drawRRect(RRect.fromRectAndRadius(body.deflate(f * 0.2), Radius.circular(f * 0.15)), p.fill(hull));
      canvas.drawLine(Offset(f * 0.1, 0), Offset(f * 1.45, 0), p.line(_darken(hull, 0.5), f * 0.18));
      canvas.drawCircle(Offset(-f * 0.05, 0), f * 0.42, p.fill(_lighten(hull, 0.15)));
      canvas.drawCircle(Offset(-f * 0.05, 0), f * 0.42, p.line(_darken(hull, 0.4), f * 0.08));
    case Glyph.howitzer:
      canvas.drawLine(Offset(-f * 0.2, 0), Offset(-f * 1.3, -f * 0.6), p.line(_metal, f * 0.14));
      canvas.drawLine(Offset(-f * 0.2, 0), Offset(-f * 1.3, f * 0.6), p.line(_metal, f * 0.14));
      canvas.drawLine(Offset(-f * 0.3, 0), Offset(f * 1.5, 0), p.line(const Color(0xFF3E4238), f * 0.3));
      canvas.drawCircle(Offset(0, -f * 0.5), f * 0.26, p.fill(_ink));
      canvas.drawCircle(Offset(0, f * 0.5), f * 0.26, p.fill(_ink));
      canvas.drawCircle(Offset(-f * 0.9, 0), f * 0.24, p.fill(color));
    case Glyph.rocketLauncher:
      final hull = Color.lerp(color, const Color(0xFF4B5040), 0.4)!;
      canvas.drawRect(Rect.fromLTWH(-f * 1.0, -f * 0.5, f * 1.4, f * 1.0), p.fill(hull));
      canvas.drawRect(Rect.fromLTWH(f * 0.45, -f * 0.42, f * 0.55, f * 0.84), p.fill(_darken(hull, 0.3)));
      for (var i = 0; i < 4; i++) {
        final y = -f * 0.33 + i * f * 0.22;
        canvas.drawLine(Offset(-f * 0.95, y), Offset(f * 0.3, y), p.line(_ink, f * 0.1));
      }
    case Glyph.antiTankGun:
      canvas.drawLine(Offset(-f * 0.1, 0), Offset(-f * 1.0, -f * 0.45), p.line(_metal, f * 0.12));
      canvas.drawLine(Offset(-f * 0.1, 0), Offset(-f * 1.0, f * 0.45), p.line(_metal, f * 0.12));
      canvas.drawLine(Offset(0, 0), Offset(f * 1.4, 0), p.line(const Color(0xFF3E4238), f * 0.14));
      canvas.drawLine(Offset(f * 0.15, -f * 0.5), Offset(f * 0.15, f * 0.5), p.line(Color.lerp(color, _metal, 0.5)!, f * 0.22));
      canvas.drawCircle(Offset(-f * 0.7, 0), f * 0.22, p.fill(color));
    case Glyph.aaGun:
      for (var i = 0; i < 4; i++) {
        final a = math.pi / 4 + i * math.pi / 2;
        canvas.drawLine(Offset.zero, Offset(math.cos(a), math.sin(a)) * f * 0.9, p.line(_metal, f * 0.12));
      }
      canvas.drawCircle(Offset.zero, f * 0.38, p.fill(Color.lerp(color, _metal, 0.4)!));
      final aim = time * 0.6 + seed;
      final d = Offset(math.cos(math.sin(aim) * 0.6), math.sin(math.sin(aim) * 0.6));
      final n = Offset(-d.dy, d.dx) * f * 0.14;
      canvas.drawLine(n, n + d * f * 1.3, p.line(_ink, f * 0.1));
      canvas.drawLine(-n, -n + d * f * 1.3, p.line(_ink, f * 0.1));
    case Glyph.plane:
    case Glyph.fighter:
      final c = Color.lerp(color, const Color(0xFF9AA0A6), 0.35)!;
      final s = g == Glyph.fighter ? f * 1.1 : f * 1.3;
      final plane = g == Glyph.fighter
          ? (Path()
            ..moveTo(s * 1.1, 0)
            ..lineTo(s * 0.2, -s * 0.15)
            ..lineTo(-s * 0.35, -s * 0.95)
            ..lineTo(-s * 0.55, -s * 0.95)
            ..lineTo(-s * 0.35, -s * 0.12)
            ..lineTo(-s * 0.9, -s * 0.12)
            ..lineTo(-s * 1.05, -s * 0.4)
            ..lineTo(-s * 1.05, s * 0.4)
            ..lineTo(-s * 0.9, s * 0.12)
            ..lineTo(-s * 0.35, s * 0.12)
            ..lineTo(-s * 0.55, s * 0.95)
            ..lineTo(-s * 0.35, s * 0.95)
            ..lineTo(s * 0.2, s * 0.15)
            ..close())
          : (Path()
            ..moveTo(s * 1.0, 0)
            ..lineTo(s * 0.55, -s * 0.12)
            ..lineTo(s * 0.25, -s * 1.1)
            ..lineTo(0, -s * 1.1)
            ..lineTo(s * 0.05, -s * 0.12)
            ..lineTo(-s * 0.75, -s * 0.1)
            ..lineTo(-s * 0.95, -s * 0.45)
            ..lineTo(-s * 1.05, -s * 0.45)
            ..lineTo(-s * 0.95, 0)
            ..lineTo(-s * 1.05, s * 0.45)
            ..lineTo(-s * 0.95, s * 0.45)
            ..lineTo(-s * 0.75, s * 0.1)
            ..lineTo(s * 0.05, s * 0.12)
            ..lineTo(0, s * 1.1)
            ..lineTo(s * 0.25, s * 1.1)
            ..lineTo(s * 0.55, s * 0.12)
            ..close());
      canvas.drawPath(plane, p.fill(c));
      canvas.drawPath(plane, p.line(_darken(c, 0.5), f * 0.08));
      if (g == Glyph.plane) {
        // Aylanayotgan vint.
        canvas.drawCircle(Offset(s * 1.02, 0), s * 0.22, p.fill(const Color(0x33FFFFFF)));
      }
    case Glyph.helicopter:
      final c = Color.lerp(color, const Color(0xFF5B6150), 0.35)!;
      canvas.drawLine(Offset.zero, Offset(-f * 1.7, 0), p.line(c, f * 0.22));
      canvas.drawLine(Offset(-f * 1.7, -f * 0.35), Offset(-f * 1.7, f * 0.35), p.line(c, f * 0.12));
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.1, 0), width: f * 1.6, height: f * 0.8), p.fill(c));
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.55, 0), width: f * 0.5, height: f * 0.45),
          p.fill(const Color(0xFF9FC3D8)));
      canvas.drawCircle(Offset.zero, f * 1.35, p.fill(const Color(0x22FFFFFF)));
      final a = time * 22 + seed;
      for (var i = 0; i < 2; i++) {
        final d = Offset(math.cos(a + i * math.pi / 2), math.sin(a + i * math.pi / 2)) * f * 1.35;
        canvas.drawLine(-d, d, p.line(const Color(0xAA222222), f * 0.08));
      }
    case Glyph.drone:
      final c = Color.lerp(color, const Color(0xFF3C3C3C), 0.4)!;
      final a = time * 30 + seed;
      for (var i = 0; i < 4; i++) {
        final d = Offset(math.cos(math.pi / 4 + i * math.pi / 2), math.sin(math.pi / 4 + i * math.pi / 2)) * f * 0.7;
        canvas.drawLine(Offset.zero, d, p.line(c, f * 0.12));
        canvas.drawCircle(d, f * 0.32, p.fill(const Color(0x33FFFFFF)));
        canvas.drawLine(d - Offset(math.cos(a), math.sin(a)) * f * 0.3, d + Offset(math.cos(a), math.sin(a)) * f * 0.3,
            p.line(const Color(0xAA222222), f * 0.06));
      }
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: f * 0.5, height: f * 0.5), p.fill(c));
    case Glyph.bunker:
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: f * 1.6, height: f * 1.6),
          Radius.circular(f * 0.35));
      canvas.drawRRect(r, p.fill(const Color(0xFF9A968C)));
      canvas.drawRRect(r, p.line(_darken(color, 0.1), f * 0.18));
      canvas.drawRect(Rect.fromLTWH(f * 0.45, -f * 0.45, f * 0.3, f * 0.9), p.fill(_ink)); // ambrazura
      canvas.drawCircle(Offset(-f * 0.25, 0), f * 0.28, p.fill(const Color(0xFF7D7970)));
    case Glyph.truck:
      final hull = Color.lerp(color, const Color(0xFF5B6143), 0.45)!;
      canvas.drawRect(Rect.fromLTWH(-f * 1.0, -f * 0.48, f * 1.35, f * 0.96), p.fill(hull));
      canvas.drawRect(Rect.fromLTWH(f * 0.4, -f * 0.4, f * 0.55, f * 0.8), p.fill(_darken(hull, 0.35)));
      canvas.drawRect(Rect.fromLTWH(-f * 1.0, -f * 0.48, f * 1.35, f * 0.96), p.line(_darken(hull, 0.5), f * 0.08));
    case Glyph.ship:
      final hull = Path()
        ..moveTo(f * 1.9, 0)
        ..lineTo(f * 1.0, -f * 0.55)
        ..lineTo(-f * 1.6, -f * 0.5)
        ..lineTo(-f * 1.6, f * 0.5)
        ..lineTo(f * 1.0, f * 0.55)
        ..close();
      canvas.drawPath(hull, p.fill(const Color(0xFF6C7278)));
      canvas.drawPath(hull, p.line(_darken(color, 0.2), f * 0.12));
      canvas.drawRect(Rect.fromCenter(center: Offset(-f * 0.2, 0), width: f * 0.8, height: f * 0.5), p.fill(color));
      canvas.drawCircle(Offset(f * 0.9, 0), f * 0.2, p.fill(_ink));
      canvas.drawCircle(Offset(-f * 1.1, 0), f * 0.2, p.fill(_ink));
  }
}

// ---------------------------------------------------------------------------
// Otlar va chavandozlar (yuqoridan ko'rinish, x — oldinga)
// ---------------------------------------------------------------------------

enum _RiderKind { sabre, knight, archer }

/// Ot (yoki tuya): tana, ko'krak, bo'yin, bosh, quloqlar, yol, dum va chopayotgan oyoqlar.
void _drawHorse(Canvas canvas, _P p, double f, Color coat,
    {required double time, required double motion, required int seed, bool heavy = false, bool camel = false,
    Color? caparison}) {
  final dark = _darken(coat, 0.25);
  final phase = time * 13 + seed; // chopish sikli
  // Oyoqlar: harakatda oldinga-orqaga cho'ziladi (yo'rtish/chopish).
  final legW = f * 0.1;
  for (final (x, y, off) in [(0.42, -0.2, 0.0), (0.42, 0.2, math.pi), (-0.45, -0.2, math.pi * 0.6), (-0.45, 0.2, math.pi * 1.6)]) {
    final swing = math.sin(phase + off) * 0.38 * motion;
    canvas.drawLine(Offset(f * x, f * y), Offset(f * (x + swing), f * (y * 1.45)), p.line(dark, legW));
  }
  // Dum: yurganda hilpiraydi.
  final tail = Path()
    ..moveTo(-f * 0.72, 0)
    ..quadraticBezierTo(-f * 1.0, f * 0.12 * math.sin(time * 4 + seed), -f * 1.18, f * 0.1 * math.sin(time * 4 + seed + 1));
  canvas.drawPath(tail, p.line(_darken(coat, 0.45), f * 0.13));
  // Tana va ko'krak.
  final bodyW = camel ? f * 1.55 : f * 1.45;
  canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.05, 0), width: bodyW, height: f * 0.54), p.fill(coat));
  canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.32, 0), width: f * 0.62, height: f * 0.58), p.fill(coat));
  if (camel) canvas.drawCircle(Offset(-f * 0.3, 0), f * 0.24, p.fill(_darken(coat, 0.12))); // o'rkach
  // Bo'yin va bosh (tuyada uzunroq).
  final neckEnd = camel ? f * 1.35 : f * 1.02;
  canvas.drawLine(Offset(f * 0.55, 0), Offset(neckEnd, 0), p.line(coat, f * (camel ? 0.18 : 0.26)));
  canvas.drawOval(Rect.fromCenter(center: Offset(neckEnd + f * 0.16, 0), width: f * 0.42, height: f * 0.24),
      p.fill(_darken(coat, 0.08)));
  if (!camel) {
    canvas.drawLine(Offset(f * 0.58, 0), Offset(f * 1.0, 0), p.line(_darken(coat, 0.5), f * 0.07)); // yol
    canvas.drawCircle(Offset(f * 1.02, -f * 0.08), f * 0.05, p.fill(dark)); // quloqlar
    canvas.drawCircle(Offset(f * 1.02, f * 0.08), f * 0.05, p.fill(dark));
  }
  if (caparison != null) {
    // Og'ir otliq: ot yopinchig'i va bosh zirhi.
    final cap = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-f * 0.02, 0), width: f * 1.35, height: f * 0.64),
        Radius.circular(f * 0.28));
    canvas.drawRRect(cap, p.fill(_darken(caparison, 0.15)));
    canvas.drawRRect(cap, p.line(const Color(0xFFD9B45A), f * 0.07));
    canvas.drawOval(Rect.fromCenter(center: Offset(f * 1.12, 0), width: f * 0.34, height: f * 0.2),
        p.fill(const Color(0xFFA8A8A0)));
  }
  if (heavy && caparison == null) {
    canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.05, 0), width: bodyW, height: f * 0.54),
        p.line(const Color(0xFF8E8E88), f * 0.06));
  }
}

/// Chavandoz: egar yopinchig'i, yelkalar, bosh (dubulg'a yoki qalpoq) va quroli.
void _drawRider(Canvas canvas, _P p, double f, Color color,
    {required _RiderKind kind, required bool charging, required double time, required int seed}) {
  // Egar yopinchig'i — tomon rangida (uzoqdan qaysi tomonligi ko'rinadi).
  canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-f * 0.05, 0), width: f * 0.5, height: f * 0.72),
          Radius.circular(f * 0.08)),
      p.fill(color));
  // Yelkalar (yuqoridan ko'ndalang oval) va bosh.
  canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.02, 0), width: f * 0.34, height: f * 0.6), p.fill(_lighten(color, 0.15)));
  canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.02, 0), width: f * 0.34, height: f * 0.6), p.line(_darken(color, 0.4), f * 0.05));
  final helmet = switch (kind) {
    _RiderKind.knight => const Color(0xFFB9B9B2),
    _RiderKind.archer => const Color(0xFF6B4A2B), // mo'ynali qalpoq
    _RiderKind.sabre => const Color(0xFF8A8A84),
  };
  canvas.drawCircle(Offset(f * 0.02, 0), f * 0.15, p.fill(helmet));
  canvas.drawCircle(Offset(f * 0.02, 0), f * 0.06, p.fill(_darken(helmet, 0.35))); // dubulg'a uchi
  switch (kind) {
    case _RiderKind.knight:
      // Nayza: zarbada oldinga tushirilgan, aks holda tik ko'tarilgan.
      if (charging) {
        canvas.drawLine(Offset(-f * 0.3, -f * 0.22), Offset(f * 2.3, -f * 0.22), p.line(const Color(0xFF4A3524), f * 0.09));
        canvas.drawLine(Offset(f * 2.1, -f * 0.22), Offset(f * 2.4, -f * 0.22), p.line(const Color(0xFFD0D0C8), f * 0.12));
        canvas.drawRect(Rect.fromLTWH(f * 1.5, -f * 0.32, f * 0.3, f * 0.2), p.fill(color)); // bayroqcha
      } else {
        canvas.drawLine(Offset(-f * 0.1, -f * 0.25), Offset(f * 0.35, -f * 0.45), p.line(const Color(0xFF4A3524), f * 0.09));
      }
      // Qalqon chap tomonda.
      canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.02, f * 0.34), width: f * 0.3, height: f * 0.2), p.fill(_lighten(color, 0.3)));
    case _RiderKind.archer:
      // Kamon: yon tomonga tortilgan.
      canvas.drawArc(Rect.fromCenter(center: Offset(f * 0.1, -f * 0.1), width: f * 0.9, height: f * 0.9), -1.2, 2.4, false,
          p.line(const Color(0xFF3A2A1A), f * 0.08));
      canvas.drawLine(Offset(-f * 0.05, -f * 0.2), Offset(f * 0.5, -f * 0.1), p.line(const Color(0xFFE8DCC0), f * 0.04));
    case _RiderKind.sabre:
      // Egilgan qilich, zarbada ko'tarilgan.
      final raise = charging ? math.sin(time * 9 + seed) * 0.25 : 0.0;
      final blade = Path()
        ..moveTo(f * 0.05, -f * 0.28)
        ..quadraticBezierTo(f * 0.45, -f * (0.45 + raise), f * 0.75, -f * (0.35 + raise));
      canvas.drawPath(blade, p.line(const Color(0xFFD0D0C8), f * 0.07));
  }
}

// ---------------------------------------------------------------------------
// Qo'mondon: oddiy va jangovar — otdagi sarkarda, bayroq, ikki soqchi
// ---------------------------------------------------------------------------

const _gold = Color(0xFFD9B45A);

/// Qo'mondon belgisi:
///  * ostida oltin halqa — bu yerda qo'mondon turibdi (uzoqdan ko'rinadi);
///  * o'rtada otdagi sarkarda (oltin dubulg'a), orqasida ikki soqchi — dushmanga qaragan;
///  * tik bayroq — tomon rangida, hukmdorda toj belgisi, oddiy sarkardada yulduz.
/// XX asr janglarida ot o'rniga shtab mashinasi va antenna.
void _drawCommander(Canvas canvas, _P p, double f, Color color,
    {required double time, required int seed, required double heading, required bool royal, required bool modern}) {
  // Oltin halqa.
  final ring = Rect.fromCenter(center: Offset.zero, width: f * 4.6, height: f * 3.4);
  canvas.drawOval(ring, p.fill(color.withValues(alpha: 0.18)));
  canvas.drawOval(ring, p.line(_gold, f * 0.16));

  canvas.save();
  canvas.rotate(heading);
  if (modern) {
    // Shtab mashinasi va ikki kuzatuvchi mashina.
    for (final o in [Offset(-f * 1.4, -f * 1.0), Offset(-f * 1.4, f * 1.0)]) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      drawGlyph(canvas, Glyph.apc, f * 0.75, color, alpha: p.alpha);
      canvas.restore();
    }
    final hull = Color.lerp(color, const Color(0xFF4B5040), 0.35)!;
    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(f * 0.2, 0), width: f * 2.0, height: f * 1.15),
        Radius.circular(f * 0.3));
    canvas.drawRRect(body, p.fill(hull));
    canvas.drawRRect(body, p.line(_gold, f * 0.1));
    canvas.drawRect(Rect.fromLTWH(f * 0.7, -f * 0.45, f * 0.4, f * 0.9), p.fill(const Color(0xFF9FC3D8)));
  } else {
    for (final o in [Offset(-f * 1.5, -f * 0.95), Offset(-f * 1.5, f * 0.95)]) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.scale(0.85);
      _drawHorse(canvas, p, f, _horseColors[(seed + o.dy.sign.toInt() + 2) % _horseColors.length],
          time: time, motion: 0, seed: seed + 3);
      _drawRider(canvas, p, f, color, kind: _RiderKind.sabre, charging: false, time: time, seed: seed);
      canvas.restore();
    }
    // Sarkarda: zirhli ot, oltin hoshiyali yopinchiq, oltin dubulg'a.
    canvas.save();
    canvas.scale(1.15);
    _drawHorse(canvas, p, f, const Color(0xFFEDE6DA), time: time, motion: 0, seed: seed, heavy: true, caparison: color);
    _drawRider(canvas, p, f, color, kind: _RiderKind.knight, charging: false, time: time, seed: seed);
    canvas.drawCircle(Offset(f * 0.02, 0), f * 0.17, p.fill(_gold));
    canvas.restore();
  }
  canvas.restore();

  // Tik bayroq (burilmaydi — doim o'qiladigan bo'lsin).
  final base = Offset(-f * 0.1, -f * 0.2), top = Offset(-f * 0.1, -f * 3.4);
  canvas.drawLine(base, top, p.line(const Color(0xFF3B2B1B), f * 0.17));
  canvas.drawCircle(top, f * 0.2, p.fill(_gold));
  final fTop = -f * 3.2, fBottom = -f * 2.0, fLen = f * 2.1;
  final flag = Path()..moveTo(top.dx, fTop);
  for (var i = 0; i <= 8; i++) {
    flag.lineTo(top.dx + fLen * i / 8, fTop + math.sin(time * 4.5 + i * 0.8) * f * 0.14 * i / 8);
  }
  for (var i = 8; i >= 0; i--) {
    flag.lineTo(top.dx + fLen * i / 8, fBottom + math.sin(time * 4.5 + i * 0.8) * f * 0.14 * i / 8);
  }
  canvas.drawPath(flag..close(), p.fill(color));
  canvas.drawPath(flag, p.line(_gold, f * 0.1));
  final mark = Offset(top.dx + fLen * 0.45, (fTop + fBottom) / 2 + math.sin(time * 4.5 + 3.6) * f * 0.07);
  if (royal) {
    // Toj.
    final w = f * 0.42, h = f * 0.3;
    canvas.drawPath(
        Path()
          ..moveTo(mark.dx - w, mark.dy + h * 0.6)
          ..lineTo(mark.dx - w, mark.dy - h * 0.4)
          ..lineTo(mark.dx - w / 2, mark.dy + h * 0.05)
          ..lineTo(mark.dx, mark.dy - h * 0.7)
          ..lineTo(mark.dx + w / 2, mark.dy + h * 0.05)
          ..lineTo(mark.dx + w, mark.dy - h * 0.4)
          ..lineTo(mark.dx + w, mark.dy + h * 0.6)
          ..close(),
        p.fill(_gold));
  } else {
    // Yulduz.
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? f * 0.3 : f * 0.13;
      final pt = mark + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(star..close(), p.fill(_gold));
  }
}

// ---------------------------------------------------------------------------
// Halok bo'lganlar, urilgan texnika va yong'in
// ---------------------------------------------------------------------------

/// Halok bo'lgan askar / ot / urilgan texnika. [alpha] — paydo bo'lish (so'nish) darajasi.
/// [modern] — XX asr askari (kaska, miltiq).
void drawFallen(Canvas canvas, Glyph g, double f, Color color, int seed, {double alpha = 1, bool modern = false}) {
  final p = _P(alpha);
  final angle = rand(seed, 3) * math.pi * 2;
  final cloth = Color.lerp(color, const Color(0xFF4A423A), 0.45)!;
  canvas.save();
  canvas.rotate(angle);

  void soldier(double s, {Offset at = Offset.zero}) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(s);
    // Yerdagi qon dog'i (xira).
    canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.1, f * 0.12), width: f * 1.1, height: f * 0.62),
        p.fill(const Color(0x475A1E1A)));
    // Oyoqlar yoyilgan.
    final legs = p.line(_darken(cloth, 0.25), f * 0.15);
    canvas.drawLine(Offset(-f * 0.32, -f * 0.1), Offset(-f * 0.82, -f * (0.22 + rand(seed, 5) * 0.15)), legs);
    canvas.drawLine(Offset(-f * 0.32, f * 0.1), Offset(-f * 0.8, f * (0.12 + rand(seed, 6) * 0.2)), legs);
    // Tana.
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: f * 0.72, height: f * 0.42),
            Radius.circular(f * 0.16)),
        p.fill(cloth));
    // Qo'l yon tomonga tashlangan.
    canvas.drawLine(Offset(f * 0.18, -f * 0.18), Offset(f * 0.45, -f * (0.5 + rand(seed, 7) * 0.2)), p.line(cloth, f * 0.12));
    // Bosh (dubulg'a/kaska).
    canvas.drawCircle(Offset(f * 0.5, 0), f * 0.16,
        p.fill(modern ? const Color(0xFF4F5440) : const Color(0xFF7A766E)));
    // Tushib qolgan quroli.
    final w0 = Offset(f * 0.1, f * 0.45), w1 = Offset(f * (modern ? 0.95 : 1.25), f * 0.25);
    canvas.drawLine(w0, w1, p.line(modern ? const Color(0xFF2E2A22) : const Color(0xFF5A4630), f * 0.08));
    canvas.restore();
  }

  switch (g) {
    case Glyph.lightHorse || Glyph.heavyHorse || Glyph.horseArcher || Glyph.camel:
      // Yonboshlab yotgan otni yuqoridan qaraganda uning YON PROFILI ko'rinadi.
      final coat = g == Glyph.camel ? const Color(0xFFB0925E) : _horseColors[seed % _horseColors.length];
      _lyingHorse(canvas, p, f * 0.95, coat, seed, caparison: g == Glyph.heavyHorse ? color : null, camel: g == Glyph.camel);
      soldier(0.8, at: Offset(-f * 0.2, -f * 1.05));
    case Glyph.elephant:
      canvas.drawOval(Rect.fromCenter(center: Offset(0, f * 0.2), width: f * 2.8, height: f * 1.6), p.fill(const Color(0x405A1E1A)));
      for (final x in [-0.7, -0.35, 0.4, 0.75]) {
        canvas.drawLine(Offset(f * x, f * 0.4), Offset(f * (x + 0.1), f * 1.0), p.line(const Color(0xFF6A6662), f * 0.3));
      }
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: f * 2.3, height: f * 1.2), p.fill(const Color(0xFF7A7672)));
      canvas.drawPath(
          Path()
            ..moveTo(f * 1.1, 0)
            ..quadraticBezierTo(f * 1.7, f * 0.2, f * 1.6, f * 0.7),
          p.line(const Color(0xFF6A6662), f * 0.25));
      canvas.save();
      canvas.rotate(0.5);
      canvas.drawRect(Rect.fromCenter(center: Offset(-f * 0.2, -f * 0.9), width: f * 0.8, height: f * 0.6), p.fill(_darken(color, 0.2)));
      canvas.restore();
    case Glyph.tank || Glyph.apc || Glyph.truck || Glyph.rocketLauncher || Glyph.howitzer || Glyph.antiTankGun ||
          Glyph.aaGun:
      // Kuygan texnika: qoraygan korpus, siljigan minora, atrofida kuyindi.
      canvas.drawCircle(
          Offset.zero,
          f * 1.6,
          Paint()
            ..shader = RadialGradient(colors: [Color.fromRGBO(20, 18, 16, 0.55 * alpha), const Color(0x00000000)])
                .createShader(Rect.fromCircle(center: Offset.zero, radius: f * 1.6)));
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: f * 1.85, height: f * 1.2), Radius.circular(f * 0.2)),
          p.fill(const Color(0xFF2C2A26)));
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: f * 1.85, height: f * 1.2), Radius.circular(f * 0.2)),
          p.line(const Color(0xFF4A3F33), f * 0.08));
      if (g == Glyph.tank) {
        final t = Offset(f * 0.9, f * 0.7);
        canvas.drawCircle(t, f * 0.38, p.fill(const Color(0xFF34312C)));
        canvas.drawLine(t, t + Offset(f * 1.0, f * 0.35), p.line(const Color(0xFF34312C), f * 0.15));
      }
    case Glyph.catapult || Glyph.cannon:
      canvas.drawLine(Offset(-f * 0.6, 0), Offset(f * 0.8, f * 0.2), p.line(const Color(0xFF3B2B1B), f * 0.3));
      canvas.drawArc(Rect.fromCircle(center: Offset(-f * 0.1, f * 0.55), radius: f * 0.28), 0, math.pi * 1.3, false,
          p.line(const Color(0xFF3B2B1B), f * 0.1));
      soldier(0.8, at: Offset(-f * 0.3, -f * 0.9));
    case Glyph.plane || Glyph.fighter || Glyph.helicopter || Glyph.drone || Glyph.ship || Glyph.bunker || Glyph.commander:
      canvas.drawCircle(Offset.zero, f * 0.9, p.fill(const Color(0x662C2A26)));
      for (var i = 0; i < 4; i++) {
        final a = rand(seed, i, 9) * math.pi * 2;
        canvas.drawRect(Rect.fromCenter(center: Offset(math.cos(a), math.sin(a)) * f * 0.7, width: f * 0.3, height: f * 0.18),
            p.fill(const Color(0xFF3F3B35)));
      }
    default:
      soldier(1.0);
  }
  canvas.restore();
}

/// Yonboshlab yotgan ot (yon profil, boshi o'ngga, oyoqlari pastga): bochkasimon tana,
/// son va kurak, egilgan bo'yin, uzun tumshuq, quloq, bo'g'imli oyoqlar va tuyoqlar, yol, dum.
void _lyingHorse(Canvas canvas, _P p, double f, Color coat, int seed, {Color? caparison, bool camel = false}) {
  final dark = _darken(coat, 0.3), light = _lighten(coat, 0.18);
  // Yerdagi soya va qon dog'i.
  canvas.drawOval(Rect.fromCenter(center: Offset(0, f * 0.28), width: f * 2.0, height: f * 0.75), p.fill(const Color(0x26000000)));
  canvas.drawOval(Rect.fromCenter(center: Offset(f * 0.2, f * 0.2), width: f * 1.2, height: f * 0.6), p.fill(const Color(0x3A5A1E1A)));

  // Oyoqlar (orqa tomondagi juftlik — to'qroq, oldinda — och). Har biri: son → tizza → tuyoq.
  void leg(List<Offset> pts, Color c, double w) {
    final path = Path()..moveTo(pts[0].dx * f, pts[0].dy * f);
    for (final q in pts.skip(1)) {
      path.lineTo(q.dx * f, q.dy * f);
    }
    canvas.drawPath(path, p.line(c, f * w)..strokeJoin = StrokeJoin.round);
    final hoof = pts.last;
    canvas.drawOval(Rect.fromCenter(center: Offset(hoof.dx * f, hoof.dy * f), width: f * 0.16, height: f * 0.11),
        p.fill(const Color(0xFF1E1A16)));
  }

  final bend = (rand(seed, 11) - 0.5) * 0.12;
  leg([const Offset(-0.5, 0.15), Offset(-0.72 + bend, 0.42), const Offset(-0.6, 0.78)], dark, 0.13);
  leg([const Offset(0.42, 0.18), Offset(0.62, 0.45 + bend), const Offset(0.8, 0.7)], dark, 0.11);
  leg([const Offset(-0.38, 0.2), const Offset(-0.3, 0.5), Offset(-0.45 + bend, 0.82)], coat, 0.14);
  leg([const Offset(0.3, 0.2), Offset(0.42 + bend, 0.52), const Offset(0.36, 0.86)], coat, 0.12);

  // Dum.
  final tail = Path()
    ..moveTo(-f * 0.78, -f * 0.12)
    ..cubicTo(-f * 1.05, -f * 0.05, -f * 1.15, f * 0.2, -f * 1.25, f * 0.45);
  canvas.drawPath(tail, p.line(_darken(coat, 0.5), f * 0.13));

  // Tana: son, bochka, kurak.
  final body = Path()
    ..moveTo(-f * 0.78, -f * 0.1)
    ..cubicTo(-f * 0.8, -f * 0.42, -f * 0.45, -f * 0.4, -f * 0.2, -f * 0.3) // sag'ri
    ..cubicTo(f * 0.1, -f * 0.26, f * 0.35, -f * 0.32, f * 0.52, -f * 0.36) // bel
    ..lineTo(f * 0.62, -f * 0.2)
    ..cubicTo(f * 0.66, f * 0.05, f * 0.55, f * 0.24, f * 0.35, f * 0.26) // ko'krak
    ..cubicTo(f * 0.05, f * 0.3, -f * 0.3, f * 0.3, -f * 0.55, f * 0.22) // qorin
    ..cubicTo(-f * 0.72, f * 0.16, -f * 0.8, f * 0.05, -f * 0.78, -f * 0.1)
    ..close();
  canvas.drawPath(body, p.fill(coat));
  // Yorug' tomon (yuqori chekka) va qorindagi soya — hajm beradi.
  canvas.save();
  canvas.clipPath(body);
  canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.05, -f * 0.28), width: f * 1.4, height: f * 0.25), p.fill(light.withValues(alpha: 0.6)));
  canvas.drawOval(Rect.fromCenter(center: Offset(-f * 0.05, f * 0.28), width: f * 1.4, height: f * 0.22), p.fill(dark.withValues(alpha: 0.6)));
  if (caparison != null) {
    canvas.drawRect(Rect.fromLTWH(-f * 0.5, -f * 0.4, f * 0.85, f * 0.75), p.fill(_darken(caparison, 0.2).withValues(alpha: 0.9)));
    canvas.drawLine(Offset(-f * 0.5, f * 0.2), Offset(f * 0.35, f * 0.2), p.line(_gold, f * 0.05));
  }
  canvas.restore();
  if (camel) canvas.drawCircle(Offset(-f * 0.1, -f * 0.36), f * 0.2, p.fill(coat)); // o'rkach

  // Bo'yin va bosh (tuyada uzunroq, pastga egilgan).
  final neckLen = camel ? 1.25 : 1.0;
  final neck = Path()
    ..moveTo(f * 0.5, -f * 0.34)
    ..cubicTo(f * 0.7 * neckLen, -f * 0.55, f * 0.85 * neckLen, -f * 0.55, f * 0.98 * neckLen, -f * 0.45)
    ..lineTo(f * 1.02 * neckLen, -f * 0.25)
    ..cubicTo(f * 0.9 * neckLen, -f * 0.2, f * 0.72, -f * 0.05, f * 0.6, f * 0.1)
    ..close();
  canvas.drawPath(neck, p.fill(coat));
  final hx = f * 0.98 * neckLen;
  final head = Path()
    ..moveTo(hx, -f * 0.5)
    ..cubicTo(hx + f * 0.15, -f * 0.52, hx + f * 0.35, -f * 0.36, hx + f * 0.45, -f * 0.22) // peshona → burun
    ..cubicTo(hx + f * 0.48, -f * 0.15, hx + f * 0.42, -f * 0.1, hx + f * 0.34, -f * 0.12) // tumshuq
    ..cubicTo(hx + f * 0.2, -f * 0.14, hx + f * 0.08, -f * 0.16, hx + f * 0.02, -f * 0.24) // jag'
    ..close();
  canvas.drawPath(head, p.fill(_darken(coat, 0.05)));
  canvas.drawCircle(Offset(hx + f * 0.4, -f * 0.18), f * 0.03, p.fill(const Color(0xFF1E1A16))); // burun teshigi
  canvas.drawCircle(Offset(hx + f * 0.14, -f * 0.36), f * 0.035, p.fill(const Color(0xFF1E1A16))); // ko'z
  if (!camel) {
    // Quloq va yol.
    canvas.drawPath(
        Path()
          ..moveTo(hx + f * 0.02, -f * 0.48)
          ..lineTo(hx - f * 0.06, -f * 0.66)
          ..lineTo(hx + f * 0.1, -f * 0.52)
          ..close(),
        p.fill(dark));
    final mane = Path()
      ..moveTo(f * 0.5, -f * 0.36)
      ..cubicTo(f * 0.7, -f * 0.58, f * 0.85, -f * 0.58, f * 0.98, -f * 0.5);
    canvas.drawPath(mane, p.line(_darken(coat, 0.55), f * 0.09));
  }
  // Egar yoki jabduq (otliqning oti ekani ko'rinsin).
  canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-f * 0.05, -f * 0.3), width: f * 0.38, height: f * 0.14),
          Radius.circular(f * 0.05)),
      p.fill(const Color(0xFF4A3524)));
}

/// Yonayotgan texnika: miltillovchi olov va ko'tarilayotgan qora tutun.
void drawFire(Canvas canvas, double f, int seed, double time, {double alpha = 1}) {
  final flick = 0.6 + 0.4 * math.sin(time * 11 + seed);
  canvas.drawCircle(Offset(0, -f * 0.2), f * 0.45 * flick, Paint()..color = Color.fromRGBO(255, 122, 26, 0.8 * alpha));
  canvas.drawCircle(Offset(0, -f * 0.25), f * 0.22 * flick, Paint()..color = Color.fromRGBO(255, 209, 102, 0.93 * alpha));
  for (var i = 0; i < 3; i++) {
    final k = (time * 0.35 + i / 3 + rand(seed, i)) % 1.0;
    canvas.drawCircle(Offset(k * f * 1.5, -f * (0.6 + k * 3.5)), f * (0.4 + k * 0.9),
        Paint()..color = Color.fromRGBO(40, 38, 36, 0.35 * (1 - k) * alpha));
  }
}

// ---------------------------------------------------------------------------
// NATO uslubidagi zaxira belgi (SVG ikon hali yuklanmagan bo'lsa)
// ---------------------------------------------------------------------------

void paintNatoSymbol(Canvas canvas, Offset c, Size size, UnitType type, Color color, {double opacity = 1}) {
  final rect = Rect.fromCenter(center: c, width: size.width, height: size.height);
  canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = color.withValues(alpha: opacity));
  final ink = Paint()
    ..color = Colors.white.withValues(alpha: opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.2, size.height / 11)
    ..strokeCap = StrokeCap.round;
  final r = rect.deflate(size.height * 0.18);
  if (type.isCommand) {
    canvas.drawCircle(r.center, r.height * 0.3, Paint()..color = Colors.white.withValues(alpha: opacity));
  } else if (type.isMounted) {
    canvas.drawLine(r.bottomLeft, r.topRight, ink);
  } else if (type.isVehicle) {
    canvas.drawOval(r.deflate(r.height * 0.15), ink);
  } else if (type.formation == Formation.battery || type.formation == Formation.fortLine) {
    canvas.drawCircle(r.center, r.height * 0.3, Paint()..color = Colors.white.withValues(alpha: opacity));
  } else if (type.isAirborne) {
    canvas.drawLine(r.centerLeft, r.centerRight, ink);
    canvas.drawLine(r.topCenter, r.bottomCenter, ink);
  } else {
    canvas.drawLine(r.topLeft, r.bottomRight, ink);
    canvas.drawLine(r.bottomLeft, r.topRight, ink);
  }
}

/// Qo'shin turining xaritadagi ko'rinishi (izohlar paneli uchun kichik saf).
class FormationPreview extends StatelessWidget {
  const FormationPreview(this.type, this.color, {super.key, this.modern = false});
  final UnitType type;
  final Color color;
  final bool modern;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(64, 40), painter: _PreviewPainter(type, color, modern));
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.type, this.color, this.modern);
  final UnitType type;
  final Color color;
  final bool modern;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
        Paint()..color = const Color(0xFFE9E1CD));
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)));
    final n = switch (type.formation) {
      Formation.single => 1,
      Formation.vee => 3,
      Formation.battery || Formation.fortLine || Formation.column => 3,
      Formation.wedge => type.glyph == Glyph.tank ? 4 : 6,
      Formation.line => type.glyph == Glyph.elephant ? 2 : 8,
      _ => 9,
    };
    const f = 4.0;
    final sp = type.figureSpacing * f;
    final glyph = type.glyphFor(modern: modern);
    final c = size.center(type.isCommand ? const Offset(-3, 7) : Offset.zero);
    for (final o in formationLayout(type.formation, n)) {
      canvas.save();
      canvas.translate(c.dx + o.dx * sp, c.dy + o.dy * sp);
      drawGlyph(canvas, glyph, f, color, seed: (o.dx * 7 + o.dy * 3).round().abs());
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.type != type || old.color != color || old.modern != modern;
}

/// Figuralar uchun tasodifiy urug' (seed).
int figureSeed(Unit u, int i) => (rand(u.label.hashCode % 1000, i) * 1000).floor();
