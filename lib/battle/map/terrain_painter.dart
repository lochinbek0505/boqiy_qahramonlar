import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models.dart';
import 'frame.dart';

/// Statik xarita qatlami (yuqoridan, 2D): landshaft rasmi + suv, o'rmon, shaharlar, yozuvlar.
/// Faqat o'lcham yoki rasm o'zgarganda qayta chiziladi va [ui.Picture] sifatida keshlanadi.
class TerrainPainter extends CustomPainter {
  TerrainPainter(this.battle, this.image, {this.compact = false});

  final Battle battle;
  final ui.Image? image;

  /// Kichik ko'rinish (bosh sahifadagi kartochka): yozuvlarsiz.
  final bool compact;

  bool get _icy => battle.biome == Biome.frost || battle.biome == Biome.snow;

  /// Videoda xarita har kadrda chiziladi — yuzlab daraxtni qayta hisoblamaslik uchun kesh.
  static final _cache = <String, ui.Picture>{};

  @override
  void paint(Canvas canvas, Size size) {
    final key = '${identityHashCode(battle)}|${identityHashCode(image)}|$compact|'
        '${size.width.round()}x${size.height.round()}';
    var pic = _cache[key];
    if (pic == null) {
      if (_cache.length > 24) _cache.clear();
      final rec = ui.PictureRecorder();
      _paintAll(Canvas(rec), size);
      pic = _cache[key] = rec.endRecording();
    }
    canvas.drawPicture(pic);
  }

  void _paintAll(Canvas canvas, Size size) {
    final g = MapGeometry(size);
    final rect = Offset.zero & size;

    if (image != null) {
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        rect,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      canvas.drawRect(rect, Paint()..color = _fallback(battle.biome));
    }

    final t = battle.terrain;
    for (final f in t.where((f) => f.kind == TerrainKind.lake)) {
      _lake(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.river)) {
      _river(canvas, g, f);
    }
    // Tog'lar va tepaliklar relyef rasmining o'zida (soya, qoya, qor) — alohida belgi chizilmaydi.
    // Daryo bo'yi to'qaylari.
    for (final f in t.where((f) => f.kind == TerrainKind.river)) {
      _riverTrees(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.forest)) {
      _forest(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.border)) {
      _border(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.rail)) {
      _rail(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.fortLine)) {
      _fortLine(canvas, g, f);
    }
    for (final f in t.where((f) => f.kind == TerrainKind.city)) {
      _city(canvas, g, f);
    }

    // Vinyetka — eski xarita effekti.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: battle.modern ? 0.14 : 0.22)],
          stops: const [0.6, 1],
          radius: 0.85,
        ).createShader(rect),
    );

    if (compact) return;
    _labels(canvas, g);
    _frame(canvas, g);
    _scaleBar(canvas, g);
    _compass(canvas, g);
  }

  Color _fallback(Biome b) => switch (b) {
        Biome.dry || Biome.arid => const Color(0xFFD2BB8A),
        Biome.steppe => const Color(0xFFC0C184),
        Biome.frost => const Color(0xFFD6D7CC),
        Biome.summer || Biome.spring => const Color(0xFFA9C07F),
        Biome.snow => const Color(0xFFEFF2F4),
      };

  // --- Suv ------------------------------------------------------------------

  Color get _waterDeep => _icy ? const Color(0xFF9FB9CC) : const Color(0xFF4F86B6);
  Color get _waterLight => _icy ? const Color(0xFFDDE8EF) : const Color(0xFF8FBCE0);

  void _river(Canvas canvas, MapGeometry g, Terrain f) {
    final pts = f.points.map(g.map).toList();
    final path = smoothPath(pts);
    final w = f.size * g.s * 0.42;
    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Qirg'oq soyasi, suv, o'rta oqim yaltirashi.
    canvas.drawPath(path, stroke(const Color(0x55433522), w + 5));
    canvas.drawPath(path, stroke(_waterDeep, w + 1.5));
    canvas.drawPath(path, stroke(_waterLight, w * 0.62));
    canvas.drawPath(path, stroke(Colors.white.withValues(alpha: 0.35), math.max(1, w * 0.14)));
  }

  void _lake(Canvas canvas, MapGeometry g, Terrain f) {
    final pts = f.points.map(g.map).toList();
    Path path;
    Offset center;
    if (pts.length == 1) {
      final r = Rect.fromCenter(center: pts[0], width: f.size * g.s * 2.4, height: f.size * g.s * 1.6);
      path = Path()..addOval(r);
      center = pts[0];
    } else {
      path = smoothPath(pts, closed: true);
      center = pts.reduce((a, b) => a + b) / pts.length.toDouble();
    }
    final bounds = path.getBounds();
    canvas.drawPath(
        path.shift(const Offset(0, 1.5)),
        Paint()
          ..color = const Color(0x44433522)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
              ((center.dx - bounds.left) / bounds.width) * 2 - 1, ((center.dy - bounds.top) / bounds.height) * 2 - 1),
          colors: [_waterDeep, _waterLight],
          radius: 0.9,
        ).createShader(bounds),
    );
    canvas.drawPath(
        path,
        Paint()
          ..color = _waterDeep.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // Qirg'oqdan bir oz ichkarida yorug' chiziq (sayoz suv).
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    canvas.restore();
  }

  // --- O'simliklar (yuqoridan ko'rinish) --------------------------------------

  /// Biom bo'yicha daraxt toji ranglari va ignabargli daraxtlar ulushi.
  (List<Color>, double) get _treeKinds => switch (battle.biome) {
        Biome.summer || Biome.spring => (
            const [Color(0xFF3E6B2E), Color(0xFF4F7A34), Color(0xFF355F2A), Color(0xFF5E8239), Color(0xFF466F30)],
            0.2
          ),
        Biome.dry || Biome.arid || Biome.steppe => (
            const [Color(0xFF5A6E36), Color(0xFF6B7A3E), Color(0xFF4E6232), Color(0xFF66733A)],
            0.1
          ),
        Biome.frost || Biome.snow => (
            const [Color(0xFF2E4632), Color(0xFF34503A), Color(0xFF6E6656), Color(0xFF7A715F)],
            0.65
          ),
      };

  /// Daraxt soyasi (janubi-sharqqa tushadi) yo'lga qo'shiladi — keyin bitta xiralashtirilgan bo'yoq bilan chiziladi.
  void _addShadow(Path shadows, Offset p, double r) {
    shadows.addOval(Rect.fromCenter(center: p + Offset(r * 0.75, r * 0.85), width: r * 2.1, height: r * 1.75));
  }

  /// Bitta daraxt toji: bargli — bir nechta bo'rtiq "bulut", ignabargli — yulduzsimon.
  /// Har bo'lak shimoli-g'arbdan yoritilgan (yorug' chekka → asosiy rang → to'q soya).
  void _crown(Canvas canvas, Offset p, double r, int seed, int i) {
    final (colors, coniferShare) = _treeKinds;
    final conifer = rand(seed, i, 7) < coniferShare;
    var base = colors[(rand(seed, i, 8) * colors.length).floor() % colors.length];
    if (conifer) base = Color.lerp(base, const Color(0xFF1F3A26), 0.35)!;
    base = Color.lerp(base, const Color(0xFF8A8A3A), (rand(seed, i, 9) - 0.6).clamp(0.0, 0.4))!;
    final lit = Color.lerp(base, const Color(0xFFE6EDB0), 0.36)!;
    final dark = Color.lerp(base, Colors.black, 0.5)!;
    Paint shaded(Offset c, double rr) => Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.5),
        radius: 1.05,
        colors: [lit, base, dark],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: c, radius: rr));

    if (conifer) {
      const n = 9;
      final rot = rand(seed, i, 10) * math.pi;
      final star = Path();
      for (var k = 0; k < n * 2; k++) {
        final a = rot + k * math.pi / n;
        final rr = k.isEven ? r * (0.85 + rand(seed, i * 31 + k, 11) * 0.2) : r * 0.5;
        final q = p + Offset(math.cos(a) * rr, math.sin(a) * rr);
        k == 0 ? star.moveTo(q.dx, q.dy) : star.lineTo(q.dx, q.dy);
      }
      star.close();
      canvas.drawPath(star, shaded(p, r));
      canvas.drawCircle(p - Offset(r * 0.12, r * 0.12), r * 0.18, Paint()..color = lit.withValues(alpha: 0.7));
      if (_icy && rand(seed, i, 12) > 0.3) {
        canvas.save();
        canvas.translate(p.dx - r * 0.15, p.dy - r * 0.15);
        canvas.scale(0.6);
        canvas.translate(-p.dx, -p.dy);
        canvas.drawPath(
            star,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.4)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25));
        canvas.restore();
      }
      return;
    }
    // Bargli daraxt: markaziy tana + atrofida 4–6 ta bo'rtiq.
    canvas.drawCircle(p, r * 0.78, shaded(p, r * 0.78));
    final lobes = 4 + (rand(seed, i, 13) * 3).floor();
    final start = rand(seed, i, 14) * math.pi * 2;
    final pts = <(Offset, double)>[];
    for (var k = 0; k < lobes; k++) {
      final a = start + k * math.pi * 2 / lobes + (rand(seed, i * 7 + k, 15) - 0.5) * 0.6;
      final d = r * (0.36 + rand(seed, i * 7 + k, 16) * 0.16);
      pts.add((p + Offset(math.cos(a) * d, math.sin(a) * d), r * (0.4 + rand(seed, i * 7 + k, 17) * 0.17)));
    }
    pts.sort((x, y) => x.$1.dy.compareTo(y.$1.dy));
    for (final (c, rr) in pts) {
      canvas.drawCircle(c, rr, shaded(c, rr));
    }
    if (_icy && rand(seed, i, 18) > 0.55) {
      canvas.drawCircle(
          p - Offset(r * 0.25, r * 0.3),
          r * 0.35,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.2));
    }
  }

  /// Yuqoridan o'rmon: notekis chekkali qorong'i soyabon qatlami, daraxt soyalari va bo'rtiq tojlar.
  void _forest(Canvas canvas, MapGeometry g, Terrain f) {
    final c = g.map(f.points[0]);
    final rx = f.size * g.s * 1.25, ry = f.size * g.s * 0.85;
    final treeR = math.max(2.4, g.s * 0.62);
    final count = (rx * ry / (treeR * treeR) * 1.05).clamp(24, 520).round();
    final seed = (f.points[0].dx * 13 + f.points[0].dy * 7).round();
    double edge(double a) => 0.86 + 0.16 * math.sin(a * 3 + seed) + 0.08 * math.sin(a * 7 + seed * 1.3);

    // O'rmon tagi: tojlar orasidagi qorong'i bo'shliqlar ochiq dala bo'lib qolmasin.
    final floor = Path();
    for (var k = 0; k <= 64; k++) {
      final a = k / 64 * math.pi * 2;
      final q = c + Offset(math.cos(a) * rx * edge(a), math.sin(a) * ry * edge(a));
      k == 0 ? floor.moveTo(q.dx, q.dy) : floor.lineTo(q.dx, q.dy);
    }
    floor.close();
    final (colors, _) = _treeKinds;
    canvas.drawPath(
        floor,
        Paint()
          ..color = Color.lerp(colors.first, Colors.black, 0.45)!.withValues(alpha: 0.85)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, treeR * 0.9));

    final trees = <(Offset, double)>[];
    for (var i = 0; i < count; i++) {
      final a = rand(seed, i, 1) * math.pi * 2;
      final d = math.sqrt(rand(seed, i, 2)) * edge(a) * 0.97;
      // Chekkadagi daraxtlar kattaroq (ko'proq yorug'lik oladi).
      final r = treeR * (0.75 + rand(seed, i, 3) * 0.5 + d * 0.15);
      trees.add((c + Offset(math.cos(a) * rx * d, math.sin(a) * ry * d), r));
    }
    trees.sort((a, b) => a.$1.dy.compareTo(b.$1.dy));
    final shadows = Path();
    for (final (t, r) in trees) {
      _addShadow(shadows, t, r);
    }
    canvas.drawPath(
        shadows,
        Paint()
          ..color = const Color(0x5A0E1808)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, treeR * 0.35));
    for (var i = 0; i < trees.length; i++) {
      _crown(canvas, trees[i].$1, trees[i].$2, seed, i);
    }
  }

  /// Daryo bo'yidagi siyrak daraxtlar (to'qay) — ikkala qirg'oq bo'ylab.
  void _riverTrees(Canvas canvas, MapGeometry g, Terrain f) {
    final path = smoothPath(f.points.map(g.map).toList());
    final halfW = f.size * g.s * 0.42 / 2;
    final treeR = math.max(2.0, g.s * 0.5);
    final seed = (f.points[0].dx * 19 + f.points[0].dy * 11).round();
    final trees = <(Offset, double)>[];
    var i = 0;
    for (final metric in path.computeMetrics()) {
      for (double d = treeR; d < metric.length; d += treeR * 1.6, i++) {
        final tan = metric.getTangentForOffset(d)!;
        final normal = Offset(-tan.vector.dy, tan.vector.dx);
        for (final side in const [-1.0, 1.0]) {
          // To'p-to'p bo'lib o'sadi: shovqin yuqori bo'lgan joyda daraxt bor.
          final grove = math.sin(d * 0.07 + seed + side * 2) + (rand(seed, i, side > 0 ? 1 : 2) - 0.5) * 1.6;
          if (grove < 0.35) continue;
          final off = halfW + treeR * (1.1 + rand(seed, i, side > 0 ? 3 : 4) * 1.6);
          final r = treeR * (0.7 + rand(seed, i, side > 0 ? 5 : 6) * 0.5);
          trees.add((tan.position + normal * off * side, r));
        }
      }
    }
    if (trees.isEmpty) return;
    trees.sort((a, b) => a.$1.dy.compareTo(b.$1.dy));
    final shadows = Path();
    for (final (t, r) in trees) {
      _addShadow(shadows, t, r);
    }
    canvas.drawPath(
        shadows,
        Paint()
          ..color = const Color(0x500E1808)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, treeR * 0.35));
    for (var k = 0; k < trees.length; k++) {
      _crown(canvas, trees[k].$1, trees[k].$2, seed + 5, k);
    }
  }

  // --- Sun'iy obyektlar -----------------------------------------------------

  void _city(Canvas canvas, MapGeometry g, Terrain f) {
    final c = g.map(f.points[0]);
    final unit = math.max(2.0, g.s * 0.42);
    final seed = (f.points[0].dx * 31 + f.points[0].dy * 17).round();
    final roof = battle.modern ? const Color(0xFF8B8680) : const Color(0xFFA0522D);
    final wall = battle.modern ? const Color(0xFFB8B2A8) : const Color(0xFFD9C7A3);
    final n = battle.modern ? 16 : 11;
    for (var i = 0; i < n; i++) {
      final a = rand(seed, i, 1) * math.pi * 2;
      final d = math.sqrt(rand(seed, i, 2)) * unit * 3.2;
      final pos = c + Offset(math.cos(a) * d, math.sin(a) * d * 0.8);
      final w = unit * (0.9 + rand(seed, i, 3) * 0.9), h = unit * (0.7 + rand(seed, i, 4) * 0.6);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate((rand(seed, i, 5) - 0.5) * 0.5);
      final r = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      // Hajmli bino: janubi-sharqqa tushgan soya, devor (yon tomoni) va ikki qiyalikli tom.
      final lift = unit * (0.55 + rand(seed, i, 6) * 0.5);
      final shadow = Path()
        ..moveTo(r.right, r.top)
        ..lineTo(r.right + lift, r.top + lift * 0.8)
        ..lineTo(r.right + lift, r.bottom + lift * 0.8)
        ..lineTo(r.left + lift, r.bottom + lift * 0.8)
        ..lineTo(r.left, r.bottom)
        ..close();
      canvas.drawPath(shadow, Paint()..color = const Color(0x44000000));
      canvas.drawRect(Rect.fromLTWH(r.left, r.bottom - lift * 0.35, r.width, lift * 0.35), Paint()..color = _darkenC(wall, 0.25));
      final top = r.shift(Offset(0, -lift * 0.35));
      canvas.drawRect(Rect.fromLTWH(top.left, top.top, top.width, top.height / 2), Paint()..color = _lightenC(roof, 0.12));
      canvas.drawRect(Rect.fromLTWH(top.left, top.center.dy, top.width, top.height / 2), Paint()..color = _darkenC(roof, 0.15));
      canvas.drawLine(top.centerLeft, top.centerRight, Paint()
        ..color = _darkenC(roof, 0.4)
        ..strokeWidth = 0.6);
      canvas.restore();
    }
    if (!battle.modern) {
      // Qal'a devori halqasi.
      canvas.drawCircle(
          c,
          unit * 3.9,
          Paint()
            ..color = const Color(0xAA6B5A45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }
  }

  void _rail(Canvas canvas, MapGeometry g, Terrain f) {
    final path = smoothPath(f.points.map(g.map).toList());
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF3B3B3B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2);
    final metric = path.computeMetrics().first;
    final tick = Paint()
      ..color = const Color(0xFF3B3B3B)
      ..strokeWidth = 1.2;
    for (double d = 0; d < metric.length; d += 7) {
      final tan = metric.getTangentForOffset(d)!;
      final n = Offset(-tan.vector.dy, tan.vector.dx) * 3.5;
      canvas.drawLine(tan.position - n, tan.position + n, tick);
    }
  }

  void _fortLine(Canvas canvas, MapGeometry g, Terrain f) {
    final path = smoothPath(f.points.map(g.map).toList());
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF5A3E22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    final metric = path.computeMetrics().first;
    final teeth = Paint()..color = const Color(0xFF5A3E22);
    for (double d = 0; d < metric.length; d += 11) {
      final tan = metric.getTangentForOffset(d)!;
      final n = Offset(-tan.vector.dy, tan.vector.dx) * 7;
      final a = tan.position - tan.vector * 3.5, b = tan.position + tan.vector * 3.5, tip = tan.position - n;
      canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(b.dx, b.dy)
            ..close(),
          teeth);
      // Bunker nuqtalari
      if ((d / 11).round() % 4 == 0) {
        canvas.drawRect(Rect.fromCenter(center: tan.position + n * 0.5, width: 4, height: 4),
            Paint()..color = const Color(0xFF444444));
      }
    }
  }

  void _border(Canvas canvas, MapGeometry g, Terrain f) {
    final path = smoothPath(f.points.map(g.map).toList());
    dashPath(
        canvas,
        path,
        Paint()
          ..color = const Color(0xAA6A1B4D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
        dash: 10,
        gap: 4,
        dot: true);
  }

  // --- Yozuvlar -------------------------------------------------------------

  void _labels(Canvas canvas, MapGeometry g) {
    final fs = g.fontSize;
    for (final f in battle.terrain) {
      final label = f.label;
      if (label == null) continue;
      final pts = f.points.map(g.map).toList();
      switch (f.kind) {
        case TerrainKind.river:
          final metric = smoothPath(pts).computeMetrics().first;
          final tan = metric.getTangentForOffset(metric.length * 0.42)!;
          var angle = math.atan2(tan.vector.dy, tan.vector.dx);
          if (angle > math.pi / 2) angle -= math.pi;
          if (angle < -math.pi / 2) angle += math.pi;
          final off = Offset(-math.sin(angle), math.cos(angle)) * (f.size * g.s * 0.42 / 2 + fs * 0.9);
          drawMapLabel(canvas, label, tan.position + off,
              fontSize: fs, italic: true, color: const Color(0xFF1C4A78), angle: angle, letterSpacing: 1);
        case TerrainKind.lake:
          final c = pts.length == 1 ? pts[0] : pts.reduce((a, b) => a + b) / pts.length.toDouble();
          drawMapLabel(canvas, label, c,
              fontSize: fs, italic: true, color: const Color(0xFF1C4A78), letterSpacing: 1);
        case TerrainKind.hill:
          drawMapLabel(canvas, label, pts[0] + Offset(0, -f.size * g.s * 0.75 - fs * 0.6),
              fontSize: fs, italic: true, color: const Color(0xFF5B3E1E));
        case TerrainKind.forest:
          drawMapLabel(canvas, label, pts[0] + Offset(0, f.size * g.s * 0.85 + fs),
              fontSize: fs, italic: true, color: const Color(0xFF274A1E));
        case TerrainKind.mountains:
          drawMapLabel(canvas, label, pts[pts.length ~/ 2] + Offset(0, -g.s * 4.5),
              fontSize: fs, italic: true, color: const Color(0xFF4E3C2A), letterSpacing: 2);
        case TerrainKind.city:
          final tp = layoutText(label, fontSize: fs * 1.05, weight: FontWeight.w700);
          final at = pts[0] + Offset(g.s * 1.8 + tp.width / 2, -g.s * 1.2);
          drawMapLabel(canvas, label, at, fontSize: fs * 1.05, weight: FontWeight.w700);
        case TerrainKind.fortLine:
          drawMapLabel(canvas, label, pts.first + Offset(-fs * 2, fs * 1.4),
              fontSize: fs, weight: FontWeight.w700, color: const Color(0xFF4A3018));
        case TerrainKind.border:
          drawMapLabel(canvas, label, pts[pts.length - 2] + Offset(0, -fs),
              fontSize: fs * 0.9, italic: true, color: const Color(0xFF6A1B4D));
        case TerrainKind.rail:
          drawMapLabel(canvas, label, pts[1] + Offset(fs * 3.4, 0),
              fontSize: fs * 0.9, italic: true, color: const Color(0xFF333333));
        case TerrainKind.label:
          drawMapLabel(canvas, label, pts[0], fontSize: fs, italic: true, color: const Color(0xFF3A3024));
      }
    }
  }

  void _frame(Canvas canvas, MapGeometry g) {
    final r = (Offset.zero & g.size).deflate(4);
    canvas.drawRect(
        r,
        Paint()
          ..color = const Color(0xAA2B2118)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    // Chetdagi daraja belgilari
    final tick = Paint()
      ..color = const Color(0xAA2B2118)
      ..strokeWidth = 1;
    for (var i = 1; i < 20; i++) {
      final x = r.left + r.width * i / 20, y = r.top + r.height * i / 20;
      final len = i % 5 == 0 ? 7.0 : 3.5;
      canvas.drawLine(Offset(x, r.top), Offset(x, r.top + len), tick);
      canvas.drawLine(Offset(x, r.bottom), Offset(x, r.bottom - len), tick);
      canvas.drawLine(Offset(r.left, y), Offset(r.left + len, y), tick);
      canvas.drawLine(Offset(r.right, y), Offset(r.right - len, y), tick);
    }
  }

  void _scaleBar(Canvas canvas, MapGeometry g) {
    // Chiroyli yaxlit masofani tanlaymiz: 1, 2, 5, 10, 20, 50 ... km
    final kmPerPx = battle.kmAcross / g.size.width;
    final target = 90 * kmPerPx;
    final mag = math.pow(10, (math.log(target) / math.ln10).floor()).toDouble();
    final km = [1, 2, 5, 10].map((m) => m * mag).lastWhere((v) => v <= target, orElse: () => mag);
    final w = km / kmPerPx;
    final origin = Offset(16, g.size.height - 22);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx - 6, origin.dy - 18, w + 12, 28), const Radius.circular(4)),
        Paint()..color = const Color(0xBBF7F2E4));
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(origin.dx + w * i / 4, origin.dy, w / 4, 4),
          Paint()..color = i.isEven ? const Color(0xFF2B2118) : Colors.white);
    }
    canvas.drawRect(
        Rect.fromLTWH(origin.dx, origin.dy, w, 4),
        Paint()
          ..color = const Color(0xFF2B2118)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
    final label = '≈ ${km >= 1 ? km.round() : km} km';
    final tp = layoutText(label, fontSize: 10.5, family: mapCondensed, color: const Color(0xFF2B2118));
    tp.paint(canvas, Offset(origin.dx, origin.dy - 15));
  }

  void _compass(Canvas canvas, MapGeometry g) {
    final r = math.max(13.0, g.s * 2.4);
    final c = Offset(g.size.width - r - 14, g.size.height - r - 16);
    canvas.drawCircle(c, r * 1.05, Paint()..color = const Color(0xAAF7F2E4));
    canvas.drawCircle(
        c,
        r * 1.05,
        Paint()
          ..color = const Color(0xFF2B2118)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 2 + i * math.pi / 2;
      final tip = c + Offset(math.cos(a), math.sin(a)) * r * 0.95;
      final side1 = c + Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) * r * 0.2;
      final side2 = c + Offset(math.cos(a - math.pi / 2), math.sin(a - math.pi / 2)) * r * 0.2;
      canvas.drawPath(Path()..moveTo(tip.dx, tip.dy)..lineTo(side1.dx, side1.dy)..lineTo(c.dx, c.dy)..close(),
          Paint()..color = i == 0 ? const Color(0xFF9E2A2B) : const Color(0xFF2B2118));
      canvas.drawPath(Path()..moveTo(tip.dx, tip.dy)..lineTo(side2.dx, side2.dy)..lineTo(c.dx, c.dy)..close(),
          Paint()..color = i == 0 ? const Color(0xFFD65A5B) : const Color(0xFF8A7B6A));
    }
    final tp = layoutText('Sh', fontSize: 10, weight: FontWeight.w700, color: const Color(0xFF9E2A2B));
    tp.paint(canvas, c + Offset(-tp.width / 2, -r * 1.05 - tp.height));
  }

  @override
  bool shouldRepaint(TerrainPainter old) =>
      old.image != image || old.battle != battle || old.compact != compact;
}

Color _darkenC(Color c, double t) => Color.lerp(c, Colors.black, t)!;
Color _lightenC(Color c, double t) => Color.lerp(c, Colors.white, t)!;

// ---------------------------------------------------------------------------
// Umumiy yo'l yordamchilari
// ---------------------------------------------------------------------------

Path smoothPath(List<Offset> pts, {bool closed = false}) {
  final path = Path();
  if (pts.isEmpty) return path;
  if (pts.length < 3) {
    path.moveTo(pts.first.dx, pts.first.dy);
    for (final q in pts.skip(1)) {
      path.lineTo(q.dx, q.dy);
    }
    return path;
  }
  if (closed) {
    final start = (pts.last + pts.first) / 2;
    path.moveTo(start.dx, start.dy);
    for (var i = 0; i < pts.length; i++) {
      final cur = pts[i], next = pts[(i + 1) % pts.length];
      final mid = (cur + next) / 2;
      path.quadraticBezierTo(cur.dx, cur.dy, mid.dx, mid.dy);
    }
    return path..close();
  }
  path.moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length - 1; i++) {
    final mid = (pts[i] + pts[i + 1]) / 2;
    path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  path.lineTo(pts.last.dx, pts.last.dy);
  return path;
}

void dashPath(Canvas canvas, Path path, Paint paint, {double dash = 6, double gap = 4, bool dot = false}) {
  for (final metric in path.computeMetrics()) {
    for (double d = 0; d < metric.length; d += dash + gap) {
      canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
      if (dot && d + dash + gap / 2 < metric.length) {
        final p = metric.getTangentForOffset(d + dash + gap / 2)!.position;
        canvas.drawCircle(p, paint.strokeWidth * 0.55, Paint()..color = paint.color);
      }
    }
  }
}
