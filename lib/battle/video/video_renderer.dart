import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/unit_catalog.dart';
import '../map/frame.dart';
import '../map/terrain_image.dart';
import '../map/terrain_painter.dart';
import '../map/units_painter.dart';
import '../models.dart';
import '../widgets/battle_hud.dart' show noteColor;
import '../widgets/epilogue.dart';

/// Video sozlamalari.
class VideoSettings {
  const VideoSettings({
    this.width = 1280,
    this.height = 720,
    this.fps = 30,
    this.secondsPerPhase = 8,
    this.introSeconds = 4,
    this.outroSeconds = 8,
    this.options = const ViewOptions(),
  });

  final int width;
  final int height;
  final int fps;
  final double secondsPerPhase;
  final double introSeconds;
  final double outroSeconds;
  final ViewOptions options;

  double durationFor(Battle b) => introSeconds + b.phases.length * secondsPerPhase + outroSeconds;
  int frameCountFor(Battle b) => (durationFor(b) * fps).ceil();
}

/// Jangni kadrma-kadr chizadi: sarlavha lavhasi → bosqichlar (xarita + yon panel) → yakun.
/// Ilovadagi xarita chizuvchilarining o'zi ishlatiladi, shuning uchun video ilovadagidek ko'rinadi.
class BattleVideoRenderer {
  BattleVideoRenderer(this.battle, this.settings);

  final Battle battle;
  final VideoSettings settings;

  final _progress = ValueNotifier<double>(0);
  final _time = ValueNotifier<double>(0);
  ui.Image? _terrain;
  late final UnitsPainter _units =
      UnitsPainter(battle: battle, progress: _progress, time: _time, options: settings.options);

  /// Landshaft va ikonlarni oldindan yuklaydi.
  Future<void> prepare() async {
    _terrain = await TerrainImages.load(battle);
    final kinds = {for (final u in battle.units) kindOf(u, modern: battle.modern), 'rally_point'};
    for (final k in kinds) {
      UnitCatalog.image(k);
    }
    for (var i = 0; i < 60; i++) {
      if (kinds.every((k) => UnitCatalog.image(k) != null)) break;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  /// [frame]-kadrni RGBA baytlar sifatida qaytaradi.
  Future<Uint8List> renderFrame(int frame) async {
    final t = frame / settings.fps;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    paintAt(canvas, t);
    final picture = rec.endRecording();
    final image = await picture.toImage(settings.width, settings.height);
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  /// [t] soniyadagi kadrni chizadi.
  void paintAt(Canvas canvas, double t) {
    final s = settings;
    final w = s.width.toDouble(), h = s.height.toDouble();
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF17120D));
    final phases = battle.phases.length;
    final battleEnd = s.introSeconds + phases * s.secondsPerPhase;
    _time.value = t;

    if (t < s.introSeconds) {
      _progress.value = 0;
      _layout(canvas, w, h, dim: 1);
      _intro(canvas, w, h, t / s.introSeconds);
    } else if (t < battleEnd) {
      _progress.value = (t - s.introSeconds) / s.secondsPerPhase;
      _layout(canvas, w, h);
    } else {
      _progress.value = phases.toDouble();
      _layout(canvas, w, h, dim: ((t - battleEnd) / 0.8).clamp(0.0, 1.0));
      _outro(canvas, w, h, (t - battleEnd) / s.outroSeconds);
    }
  }

  // --- Asosiy ko'rinish: sarlavha, xarita, yon panel, bosqichlar tasmasi --------------

  void _layout(Canvas canvas, double w, double h, {double dim = 0}) {
    final u = h / 720; // masshtab birligi
    final pad = 18 * u, top = 62 * u, bottom = 64 * u;
    final mapH = h - top - bottom - pad;
    final mapW = mapH * 1.6;
    final mapRect = Rect.fromLTWH(pad, top, mapW, mapH);
    final side = Rect.fromLTRB(mapRect.right + pad, top, w - pad, top + mapH);
    final f = BattleFrame(battle, _progress.value);

    // Sarlavha.
    _text(canvas, battle.name, Offset(pad, 14 * u), size: 26 * u, color: const Color(0xFFF3E6CC), serif: true, bold: true,
        maxWidth: w * 0.6);
    _text(canvas, '${battle.date} · ${battle.tactic}', Offset(pad, 44 * u), size: 13 * u, color: const Color(0xFFBFAF93),
        maxWidth: w * 0.62);
    // Kuchlar (o'ng tepada).
    var x = w - pad;
    for (final sd in Side.values.reversed) {
      final n = formatCount(f.soldiers(sd));
      final nw = _measure(n, 17 * u, bold: true);
      x -= nw;
      _text(canvas, n, Offset(x, 22 * u), size: 17 * u, bold: true, color: Color.lerp(battle.colorOf(sd), Colors.white, 0.45)!);
      final nameW = _measure(battle.nameOf(sd), 13 * u);
      x -= nameW + 8 * u;
      _text(canvas, battle.nameOf(sd), Offset(x, 25 * u), size: 13 * u, color: const Color(0xFFD9C8A8));
      x -= 16 * u;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 28 * u, 11 * u, 11 * u), Radius.circular(2 * u)),
          Paint()..color = battle.colorOf(sd));
      x -= 22 * u;
    }

    // Xarita.
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(mapRect, Radius.circular(10 * u)));
    canvas.translate(mapRect.left, mapRect.top);
    TerrainPainter(battle, _terrain).paint(canvas, mapRect.size);
    _units.paint(canvas, mapRect.size);
    _noteMarkers(canvas, mapRect.size, f, u);
    canvas.restore();
    canvas.drawRRect(
        RRect.fromRectAndRadius(mapRect, Radius.circular(10 * u)),
        Paint()
          ..color = const Color(0xFF6D4C2F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * u);

    // Yon panel: bosqich matni, voqealar.
    final phase = battle.phases[f.phase];
    final appear = (f.phaseT / 0.08).clamp(0.0, 1.0); // yangi bosqich matni sekin paydo bo'ladi
    var y = side.top;
    canvas.drawRRect(RRect.fromRectAndRadius(side, Radius.circular(10 * u)), Paint()..color = const Color(0xFF231B14));
    final inner = side.deflate(16 * u);
    y = inner.top;
    _text(canvas, '${f.phase + 1}-BOSQICH / ${battle.phases.length}', Offset(inner.left, y), size: 12 * u,
        color: const Color(0xFFE0B25B), bold: true, opacity: appear);
    y += 20 * u;
    y += _text(canvas, phase.title, Offset(inner.left, y), size: 22 * u, serif: true, bold: true,
        color: const Color(0xFFF3E6CC), maxWidth: inner.width, maxLines: 2, opacity: appear);
    y += 8 * u;
    y += _text(canvas, phase.text, Offset(inner.left, y), size: 14 * u, color: const Color(0xFFE6DAC3),
        maxWidth: inner.width, maxLines: 12, height: 1.4, opacity: appear);
    y += 14 * u;
    for (var i = 0; i < phase.notes.length; i++) {
      final a = ((f.phaseT - 0.03 - i * 0.03) / 0.06).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final note = phase.notes[i];
      final c = Offset(inner.left + 11 * u, y + 11 * u);
      canvas.drawCircle(c, 11 * u, Paint()..color = noteColor(note.kind).withValues(alpha: a));
      _text(canvas, '${i + 1}', c - Offset(4 * u, 8 * u), size: 12 * u, bold: true, color: Colors.white, opacity: a);
      y += math.max(24 * u,
          _text(canvas, note.text, Offset(inner.left + 30 * u, y + 2 * u), size: 14 * u, serif: true,
                  color: const Color(0xFFF3E6CC), maxWidth: inner.width - 30 * u, maxLines: 2, opacity: a) +
              4 * u);
      y += 6 * u;
    }

    // Pastda: bosqichlar tasmasi.
    final tl = Rect.fromLTWH(pad, h - bottom + 10 * u, w - pad * 2, 40 * u);
    final segW = tl.width / battle.phases.length;
    for (var i = 0; i < battle.phases.length; i++) {
      final r = Rect.fromLTWH(tl.left + i * segW + 3 * u, tl.top, segW - 6 * u, (i == f.phase ? 7 : 5) * u);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(3 * u)), Paint()..color = const Color(0xFF3A2E24));
      final fill = (_progress.value - i).clamp(0.0, 1.0);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width * fill, r.height), Radius.circular(3 * u)),
          Paint()..color = i == f.phase ? const Color(0xFFB07A3A) : const Color(0x99B07A3A));
      _text(canvas, '${i + 1}. ${battle.phases[i].title}', Offset(r.left, r.bottom + 4 * u), size: 11.5 * u,
          bold: i == f.phase,
          color: i == f.phase ? const Color(0xFFE0B25B) : const Color(0x99F3E6CC),
          maxWidth: r.width, maxLines: 1);
    }
    _text(canvas, 'Buyuk jang taktikalari', Offset(w - pad - _measure('Buyuk jang taktikalari', 11 * u), 46 * u),
        size: 11 * u, color: const Color(0x66F3E6CC));

    if (dim > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Color.fromRGBO(10, 8, 6, 0.72 * dim));
    }
  }

  void _noteMarkers(Canvas canvas, Size size, BattleFrame f, double u) {
    final notes = battle.phases[f.phase].notes;
    for (var i = 0; i < notes.length; i++) {
      final a = ((f.phaseT - 0.03 - i * 0.03) / 0.06).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final c = Offset(notes[i].pos.dx / 100 * size.width, notes[i].pos.dy / 100 * size.height);
      final color = noteColor(notes[i].kind);
      final pulse = (_time.value * 0.7) % 1.0;
      canvas.drawCircle(
          c,
          11 * u * (1 + pulse * 1.2),
          Paint()
            ..color = color.withValues(alpha: (1 - pulse) * a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * u);
      canvas.drawCircle(c, 11 * u, Paint()..color = color.withValues(alpha: a));
      canvas.drawCircle(
          c,
          11 * u,
          Paint()
            ..color = Colors.white.withValues(alpha: a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * u);
      _text(canvas, '${i + 1}', c - Offset(4 * u, 8 * u), size: 12 * u, bold: true, color: Colors.white, opacity: a);
    }
  }

  // --- Sarlavha lavhasi -------------------------------------------------------------

  void _intro(Canvas canvas, double w, double h, double k) {
    final u = h / 720;
    final inA = Curves.easeOut.transform((k / 0.25).clamp(0.0, 1.0));
    final outA = 1 - ((k - 0.82) / 0.18).clamp(0.0, 1.0);
    final a = inA * outA;
    final cx = w / 2;
    var y = h * 0.26;
    y += _text(canvas, battle.commander.toUpperCase(), Offset(cx, y), size: 16 * u, color: const Color(0xFFE0B25B),
        bold: true, center: true, opacity: a, letterSpacing: 3 * u);
    y += 12 * u;
    y += _text(canvas, battle.name, Offset(cx, y + (1 - inA) * 20 * u), size: 52 * u, serif: true, bold: true,
        color: const Color(0xFFF3E6CC), center: true, opacity: a, maxWidth: w * 0.85, maxLines: 2);
    y += 10 * u;
    y += _text(canvas, battle.date, Offset(cx, y), size: 20 * u, color: const Color(0xFFD9C8A8), center: true, opacity: a);
    y += 26 * u;
    canvas.drawLine(Offset(cx - 60 * u, y), Offset(cx + 60 * u, y),
        Paint()
          ..color = const Color(0xFFE0B25B).withValues(alpha: a)
          ..strokeWidth = 2 * u);
    y += 22 * u;
    y += _text(canvas, battle.tactic, Offset(cx, y), size: 18 * u, serif: true, color: const Color(0xFFF3E6CC),
        center: true, opacity: a, maxWidth: w * 0.7, maxLines: 2);
    y += 34 * u;
    final vs = '${battle.sideA}   —   ${battle.sideB}';
    _text(canvas, vs, Offset(cx, y), size: 20 * u, bold: true, color: const Color(0xFFF3E6CC), center: true, opacity: a);
  }

  // --- Yakun lavhasi: g'olib, yo'qotishlar, oqibatlar ---------------------------------

  void _outro(Canvas canvas, double w, double h, double k) {
    final u = h / 720;
    final o = BattleOutcome.of(battle);
    final win = battle.colorOf(o.winner);
    final a = Curves.easeOut.transform((k / 0.12).clamp(0.0, 1.0));
    final panel = Rect.fromCenter(center: Offset(w / 2, h / 2), width: math.min(w * 0.72, 900 * u), height: h * 0.8);
    canvas.drawRRect(RRect.fromRectAndRadius(panel, Radius.circular(18 * u)),
        Paint()..color = const Color(0xFFFBF7EE).withValues(alpha: a));
    final head = Rect.fromLTWH(panel.left, panel.top, panel.width, 120 * u);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndCorners(head, topLeft: Radius.circular(18 * u), topRight: Radius.circular(18 * u)));
    canvas.drawRect(
        head,
        Paint()
          ..shader = LinearGradient(colors: [Color.lerp(win, Colors.black, 0.35)!, win])
              .createShader(head)
          ..color = Colors.white.withValues(alpha: a));
    canvas.restore();
    // Oltin nishon (kattalashib chiqadi).
    final badge = Offset(head.left + 70 * u, head.center.dy);
    final pop = Curves.elasticOut.transform((k / 0.2).clamp(0.0, 1.0));
    canvas.drawCircle(badge, 36 * u * pop, Paint()..color = const Color(0x33FFFFFF));
    canvas.drawCircle(
        badge,
        36 * u * pop,
        Paint()
          ..color = const Color(0xFFE0B25B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * u);
    final icon = UnitCatalog.image('rally_point');
    if (icon != null && pop > 0.05) {
      canvas.drawImageRect(icon, Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromCircle(center: badge, radius: 22 * u * pop),
          Paint()..colorFilter = const ColorFilter.mode(Color(0xFFFFF4D6), BlendMode.srcIn));
    }
    final tx = head.left + 130 * u;
    _text(canvas, 'JANG YAKUNI', Offset(tx, head.top + 22 * u), size: 13 * u, bold: true, color: const Color(0xCCFFF4D6),
        opacity: a, letterSpacing: 2 * u);
    _text(canvas, 'G\'alaba: ${battle.nameOf(o.winner)}', Offset(tx, head.top + 40 * u), size: 30 * u, serif: true,
        bold: true, color: Colors.white, opacity: ((k - 0.05) / 0.1).clamp(0.0, 1.0), maxWidth: head.right - tx - 20 * u);
    _text(canvas, battle.facts.result, Offset(tx, head.top + 82 * u), size: 14 * u, color: const Color(0xE6FFFFFF),
        opacity: ((k - 0.1) / 0.1).clamp(0.0, 1.0), maxWidth: head.right - tx - 20 * u, maxLines: 2);

    // Tomonlar: kuch chizig'i qisqarib, sanoq kamayib boradi.
    var y = head.bottom + 26 * u;
    final bx = panel.left + 36 * u, bw = panel.width - 72 * u;
    for (final (i, sd) in [o.winner, o.loser].indexed) {
      final r = o.sides[sd]!;
      final c = battle.colorOf(sd);
      final p = Curves.easeOutCubic.transform(((k - 0.15 - i * 0.08) / 0.3).clamp(0.0, 1.0));
      final shown = (r.start - (r.start - r.remaining) * p).round();
      canvas.drawCircle(Offset(bx + 6 * u, y + 10 * u), 6 * u, Paint()..color = c);
      _text(canvas, battle.nameOf(sd), Offset(bx + 20 * u, y), size: 17 * u, bold: true, color: const Color(0xFF2B2118));
      final num = '${formatCount(shown)} / ${formatCount(r.start)}';
      _text(canvas, num, Offset(bx + bw - _measure(num, 17 * u, bold: true), y), size: 17 * u, bold: true, color: c);
      y += 28 * u;
      final bar = Rect.fromLTWH(bx, y, bw, 12 * u);
      canvas.drawRRect(RRect.fromRectAndRadius(bar, Radius.circular(6 * u)), Paint()..color = c.withValues(alpha: 0.15));
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(bx, y, bw * (r.start == 0 ? 0 : shown / r.start), 12 * u), Radius.circular(6 * u)),
          Paint()..color = c);
      y += 20 * u;
      final parts = [
        'Halok, yarador, asir: ~${formatCount((r.lost * p).round())}',
        if (r.defected > 0) 'Tomon o\'zgartirdi: ~${formatCount((r.defected * p).round())}',
        if (r.left > 0) 'Maydondan chiqdi: ~${formatCount((r.left * p).round())}',
      ];
      _text(canvas, parts.join('    '), Offset(bx, y), size: 13 * u, color: const Color(0xFF6B5A45));
      y += 34 * u;
    }
    if (battle.aftermath.isNotEmpty) {
      final aa = ((k - 0.5) / 0.15).clamp(0.0, 1.0);
      _text(canvas, 'JANGDAN KEYIN', Offset(bx, y), size: 12 * u, bold: true, color: const Color(0xFF8A7B66), opacity: aa,
          letterSpacing: 1.5 * u);
      y += 20 * u;
      _text(canvas, battle.aftermath, Offset(bx, y), size: 16 * u, serif: true, color: const Color(0xFF2B2118),
          opacity: aa, maxWidth: bw, maxLines: 6, height: 1.45);
    }
    _text(canvas, 'Buyuk jang taktikalari', Offset(panel.center.dx, panel.bottom - 30 * u), size: 12 * u,
        color: const Color(0x998A7B66), center: true, opacity: a);
  }

  // --- Matn yordamchilari -----------------------------------------------------------

  TextPainter _painter(String text, double size,
      {bool bold = false, bool serif = false, Color color = Colors.white, double? maxWidth, int? maxLines,
      double height = 1.2, double letterSpacing = 0, bool center = false}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: serif ? mapSerif : mapCondensed,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: maxLines,
      ellipsis: maxLines != null ? '…' : null,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  double _measure(String text, double size, {bool bold = false}) => _painter(text, size, bold: bold).width;

  /// Matn chizadi va uning balandligini qaytaradi.
  double _text(Canvas canvas, String text, Offset at,
      {required double size,
      bool bold = false,
      bool serif = false,
      Color color = Colors.white,
      double? maxWidth,
      int? maxLines,
      double height = 1.2,
      double opacity = 1,
      double letterSpacing = 0,
      bool center = false}) {
    if (opacity <= 0.01) return 0;
    final tp = _painter(text, size,
        bold: bold,
        serif: serif,
        color: color.withValues(alpha: color.a * opacity),
        maxWidth: maxWidth,
        maxLines: maxLines,
        height: height,
        letterSpacing: letterSpacing,
        center: center);
    tp.paint(canvas, center ? at - Offset(tp.width / 2, 0) : at);
    return tp.height;
  }
}

/// Eksport natijasi.
class VideoExportResult {
  const VideoExportResult({required this.fileName, required this.bytes, required this.elapsed, this.data});
  final String fileName;
  final int bytes;
  final Duration elapsed;

  /// Fayl mazmuni (faqat `download: false` bo'lganda saqlanadi).
  final Uint8List? data;
}

/// Foydalanuvchi eksportni bekor qildi.
class VideoExportCancelled implements Exception {
  const VideoExportCancelled();
}
