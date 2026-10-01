import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../models.dart';

/// Bosqich ichidagi vaqt taqsimoti — tomoshabin nima bo'layotganini tushunib ulgurishi uchun:
///  * [introShare] gacha — «tayyorgarlik»: sarlavha almashadi, voqea belgilari paydo bo'ladi,
///    qo'shinlar hali joyida;
///  * [introShare]..[introShare]+[moveShare] — qo'shinlar strelka bo'ylab harakatlanadi;
///  * qolgani — yetib kelgan joyida jang (effektlar davom etadi), keyingi bosqichga o'tishdan oldin.
const double introShare = 0.15;
const double moveShare = 0.6;

/// Harakat yo'lining egriligi (oraliq nuqtalar berilmaganda).
Offset curveControl(Offset a, Offset b) => (a + b) / 2 + Offset(-(b - a).dy, (b - a).dx) * 0.12;

Offset bezier(Offset a, Offset c, Offset b, double t) {
  final u = 1 - t;
  return a * (u * u) + c * (2 * u * t) + b * (t * t);
}

Offset bezierTangent(Offset a, Offset c, Offset b, double t) =>
    (c - a) * (2 * (1 - t)) + (b - c) * (2 * t);

/// Bir bosqichdagi harakat yo'li (xarita koordinatalarida). Oraliq nuqtalar bo'lsa
/// Catmull-Rom egri chizig'i, bo'lmasa bitta yumshoq yoy. Uzunlik bo'yicha
/// parametrlangan — bo'linma yo'l bo'ylab bir tekis tezlikda yuradi.
class MovePath {
  MovePath(List<Offset> pts) {
    const n = 48;
    final raw = <Offset>[];
    if (pts.length == 2) {
      final c = curveControl(pts[0], pts[1]);
      for (var i = 0; i <= n; i++) {
        raw.add(bezier(pts[0], c, pts[1], i / n));
      }
    } else {
      final ext = [pts.first * 2 - pts[1], ...pts, pts.last * 2 - pts[pts.length - 2]];
      final per = (n / (pts.length - 1)).ceil();
      for (var seg = 1; seg < ext.length - 2; seg++) {
        for (var i = 0; i < per; i++) {
          raw.add(_catmull(ext[seg - 1], ext[seg], ext[seg + 1], ext[seg + 2], i / per));
        }
      }
      raw.add(pts.last);
    }
    points = raw;
    lengths = [0];
    for (var i = 1; i < raw.length; i++) {
      lengths.add(lengths.last + (raw[i] - raw[i - 1]).distance);
    }
  }

  late final List<Offset> points;
  late final List<double> lengths;
  double get length => lengths.last;

  static Offset _catmull(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final t2 = t * t, t3 = t2 * t;
    return (p1 * 2 + (p2 - p0) * t + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * t2 + (p1 * 3 - p0 - p2 * 3 + p3) * t3) * 0.5;
  }

  int _index(double t) {
    final target = t.clamp(0.0, 1.0) * length;
    var lo = 0, hi = lengths.length - 1;
    while (lo < hi - 1) {
      final mid = (lo + hi) >> 1;
      if (lengths[mid] < target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  Offset at(double t) {
    if (length == 0) return points.first;
    final i = _index(t);
    final target = t.clamp(0.0, 1.0) * length;
    final seg = lengths[i + 1] - lengths[i];
    final f = seg == 0 ? 0.0 : (target - lengths[i]) / seg;
    return Offset.lerp(points[i], points[i + 1], f)!;
  }

  Offset tangent(double t) {
    final i = _index(t);
    return points[math.min(i + 1, points.length - 1)] - points[i];
  }

  static final _cache = Expando<Map<int, MovePath>>();

  /// k-bosqichdagi yo'l (k >= 1), keshlanadi.
  static MovePath of(Unit u, int k) {
    final m = _cache[u] ??= {};
    return m[k] ??= MovePath([u.positions[k - 1], ...?u.via[k], u.positions[k]]);
  }
}

/// Animatsiya holati: [progress] 0..phases.length oralig'ida.
/// k-bosqich [k, k+1) oralig'ini egallaydi.
class BattleFrame {
  BattleFrame(this.battle, double progress)
      : progress = progress.clamp(0, battle.phases.length).toDouble() {
    final n = battle.phases.length;
    phase = math.min(this.progress.floor(), n - 1);
    phaseT = (this.progress - phase).clamp(0.0, 1.0);
    move = Curves.easeInOutCubic.transform(((phaseT - introShare) / moveShare).clamp(0.0, 1.0));
  }

  final Battle battle;
  final double progress;
  late final int phase;

  /// Bosqich ichidagi xom vaqt (0..1).
  late final double phaseT;

  /// Joriy bosqichdagi harakat ulushi (0..1, silliqlangan).
  late final double move;

  /// Grafikdagi x o'qi: 0 — boshlanish, k — k-bosqich oxiri.
  double get chartX => phase == 0 ? 0 : phase - 1 + move;

  Offset positionOf(Unit u) {
    if (phase == 0) return u.positions[0];
    return MovePath.of(u, phase).at(move);
  }

  /// Harakat yo'nalishi (xarita koordinatalarida), harakatsiz bo'lsa null.
  Offset? moveDirection(Unit u) {
    if (!moves(u)) return null;
    return MovePath.of(u, phase).tangent(move);
  }

  bool moves(Unit u) => phase > 0 && MovePath.of(u, phase).length > 1.5;

  /// Harakat tezligi omili: boshida va oxirida 0, o'rtada 1.
  double speedOf(Unit u) => moves(u) && move < 1 ? math.sin(math.pi * move) : 0;

  double strengthOf(Unit u) {
    if (phase == 0) return u.strengthAt(0);
    return ui.lerpDouble(u.strengthAt(phase - 1), u.strengthAt(phase), move)!;
  }

  /// Ko'rinish darajasi: 0 — xaritada yo'q, 1 — to'liq. Qo'shimcha kuch paydo bo'lganda
  /// sekin ko'rinadi, chiqib ketayotganda so'nadi.
  double presenceOf(Unit u) {
    if (u.appearAt != null) {
      if (phase < u.appearAt!) return 0;
      if (phase == u.appearAt!) return (phaseT / (introShare + 0.1)).clamp(0.0, 1.0);
    }
    if (u.leaveAt != null) {
      if (phase > u.leaveAt!) return 0;
      if (phase == u.leaveAt!) return 1 - move;
    }
    return 1;
  }

  /// Yashirinlik: 1 — to'liq yashirin (pistirma), 0 — ochiq.
  double hiddenOf(Unit u) {
    final h = u.hiddenUntil;
    if (h == null || phase > h) return 0;
    if (phase < h) return 1;
    return 1 - move;
  }

  /// Bu bosqichda bo'linma harakatlandimi yoki talafot ko'rdimi — ya'ni jangda faolmi.
  bool active(Unit u) =>
      phase > 0 &&
      presenceOf(u) > 0.5 &&
      hiddenOf(u) < 0.5 &&
      (moves(u) || (u.strengthAt(phase) - u.strengthAt(phase - 1)).abs() > 0.02);

  Side sideOf(Unit u) => phase == 0 ? u.sideAt(0) : (move < 0.5 ? u.sideAt(phase - 1) : u.sideAt(phase));

  Color colorOf(Unit u) {
    final before = battle.colorOf(u.sideAt(math.max(phase - 1, 0)));
    final now = battle.colorOf(u.sideAt(phase));
    return Color.lerp(before, now, phase == 0 ? 1 : move)!;
  }

  Stance stanceOf(Unit u) => stancesOf(battle, u)[phase];

  /// Xaritadagi askarlar soni (tomon bo'yicha, animatsiya bilan silliq).
  int soldiers(Side side) {
    var total = 0.0;
    for (final u in battle.units) {
      if (!u.countsAsSoldiers || sideOf(u) != side) continue;
      total += u.count * strengthOf(u) * presenceOf(u);
    }
    return total.round();
  }
}

final _stanceCache = Expando<List<Stance>>();

/// Har bosqichdagi holat: qo'lda berilgani yoki harakat va talafotdan avtomatik.
///  * dushman tomon yurish — hujum; otliq dushmanga yaqinlashsa — zarba;
///  * dushmandan uzoqlashish — chekinish, katta talafot bilan — tartibsiz qochish;
///  * joyida turib talafot ko'rish — mudofaa.
List<Stance> stancesOf(Battle b, Unit u) => _stanceCache[u] ??= [
      for (var k = 0; k < b.phases.length; k++) u.stances[k] ?? _autoStance(b, u, k),
    ];

Stance _autoStance(Battle b, Unit u, int k) {
  if (u.hiddenUntil != null && k < u.hiddenUntil!) return Stance.hidden;
  if (k == 0) return Stance.hold;
  final from = u.positions[k - 1], to = u.positions[k];
  final moveVec = to - from;
  final drop = u.strengthAt(k - 1) - u.strengthAt(k);
  // Bosqich boshidagi eng yaqin dushman.
  Offset? enemy;
  var best = double.infinity;
  for (final o in b.units) {
    if (o.sideAt(k - 1) == u.sideAt(k - 1) || o.type.isAirborne || !o.presentAt(k - 1)) continue;
    final d = (o.positions[k - 1] - from).distance;
    if (d < best) {
      best = d;
      enemy = o.positions[k - 1];
    }
  }
  if (moveVec.distance > 1.5) {
    if (enemy == null) return Stance.advance;
    final toEnemy = enemy - from;
    final dot = (moveVec.dx * toEnemy.dx + moveVec.dy * toEnemy.dy) / (moveVec.distance * toEnemy.distance + 1e-6);
    if (dot < -0.25) return drop > 0.15 ? Stance.rout : Stance.retreat;
    final endDist = (enemy - to).distance;
    if (u.type.isMounted && dot > 0.2 && endDist < 16) return Stance.charge;
    return Stance.advance;
  }
  return drop > 0.03 ? Stance.defend : Stance.hold;
}

/// 0..100 koordinatalarni ekran piksellariga o'tkazadi.
class MapGeometry {
  MapGeometry(this.size)
      : s = size.width / 100,
        fig = (size.width / 100 * 0.6).clamp(2.8, 7.5).toDouble(),
        fontSize = (size.width / 100 * 1.12).clamp(9, 13).toDouble();

  final Size size;

  /// 1 xarita birligi necha piksel (gorizontal).
  final double s;

  /// Bitta figura (askar/otliq/tank) o'lchami, pikselda.
  final double fig;
  final double fontSize;

  Offset map(Offset p) => Offset(p.dx * size.width / 100, p.dy * size.height / 100);
  Offset unmap(Offset px) => Offset(px.dx / size.width * 100, px.dy / size.height * 100);

  /// Xarita koordinatasidagi vektorni ekran vektoriga aylantiradi.
  Offset vec(Offset v) => Offset(v.dx * size.width / 100, v.dy * size.height / 100);
}

// ---------------------------------------------------------------------------
// Matn chizish (xarita uslubidagi oq halo bilan)
// ---------------------------------------------------------------------------

const mapSerif = 'PTSerif';
const mapCondensed = 'RobotoCondensed';

TextPainter layoutText(
  String text, {
  required double fontSize,
  Color color = const Color(0xFF222222),
  String family = mapSerif,
  FontWeight weight = FontWeight.w400,
  bool italic = false,
  double letterSpacing = 0,
  Paint? foreground,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
        color: foreground == null ? color : null,
        foreground: foreground,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
}

/// Xarita yozuvi: atrofida yorug' «halo», o'qilishi oson bo'lishi uchun.
void drawMapLabel(
  Canvas canvas,
  String text,
  Offset center, {
  required double fontSize,
  Color color = const Color(0xFF2A2118),
  Color halo = const Color(0xDDF7F2E4),
  FontWeight weight = FontWeight.w400,
  bool italic = false,
  double letterSpacing = 0,
  double angle = 0,
  String family = mapSerif,
}) {
  final haloPainter = layoutText(text,
      fontSize: fontSize,
      family: family,
      weight: weight,
      italic: italic,
      letterSpacing: letterSpacing,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = halo);
  final fill = layoutText(text,
      fontSize: fontSize, family: family, weight: weight, italic: italic, letterSpacing: letterSpacing, color: color);
  canvas.save();
  canvas.translate(center.dx, center.dy);
  if (angle != 0) canvas.rotate(angle);
  final o = Offset(-fill.width / 2, -fill.height / 2);
  haloPainter.paint(canvas, o);
  fill.paint(canvas, o);
  canvas.restore();
}

/// Deterministik psevdo-tasodifiy son [0,1).
double rand(int a, [int b = 0, int c = 0]) {
  final v = math.sin(a * 12.9898 + b * 78.233 + c * 37.719) * 43758.5453;
  return v - v.floorToDouble();
}
