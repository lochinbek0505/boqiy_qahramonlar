import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/unit_catalog.dart';
import '../models.dart';
import 'figures.dart';
import 'frame.dart';
import 'terrain_painter.dart';

class ViewOptions {
  const ViewOptions({
    this.labels = true,
    this.counts = true,
    this.effects = true,
    this.arrows = true,
    this.badges = true,
    this.grid = false,
  });
  final bool labels;
  final bool counts;
  final bool effects;
  final bool arrows;

  /// Bo'linma turi ikonkasi (SVG) — nom va son o'chirilgan bo'lsa ham ko'rinadi.
  final bool badges;

  /// Koordinata to'ri (0..100) — yangi jang qo'shayotganda joy tanlash uchun.
  final bool grid;

  ViewOptions copyWith({bool? labels, bool? counts, bool? effects, bool? arrows, bool? badges, bool? grid}) =>
      ViewOptions(
        labels: labels ?? this.labels,
        counts: counts ?? this.counts,
        effects: effects ?? this.effects,
        arrows: arrows ?? this.arrows,
        badges: badges ?? this.badges,
        grid: grid ?? this.grid,
      );
}

/// Har kadrda bo'linma holati (hisob-kitob bir marta bajariladi).
class _UnitState {
  _UnitState(this.unit, this.pos, this.px, this.side, this.color, this.strength, this.speed, this.active,
      this.presence, this.hidden, this.stance, this.glyph, this.weapon, this.n);
  final Unit unit;
  final Offset pos; // xarita koordinatasi
  final Offset px; // piksel
  final Side side;
  final Color color;
  final double strength;
  final double speed;
  final bool active;
  final double presence; // 0..1 — paydo bo'lish / chiqib ketish
  final double hidden; // 0..1 — pistirma
  final Stance stance;
  final Glyph glyph;
  final Weapon weapon;
  final int n; // figuralar soni
  Offset heading = const Offset(1, 0); // piksel fazosida birlik vektor
  double radius = 0;

  UnitType get type => unit.type;
  bool get visibleToEnemy => presence > 0.5 && hidden < 0.5;
}

/// Dinamik qatlam: qo'shinlar, strelkalar, jang effektlari.
class UnitsPainter extends CustomPainter {
  UnitsPainter({
    required this.battle,
    required this.progress,
    required this.time,
    this.options = const ViewOptions(),
    this.selected,
  }) : super(repaint: Listenable.merge([progress, time, UnitCatalog.version]));

  final Battle battle;
  final ValueListenable<double> progress;
  final ValueListenable<double> time;
  final ViewOptions options;
  final Unit? selected;

  bool get _modern => battle.modern;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = BattleFrame(battle, progress.value);
    final g = MapGeometry(size);
    final t = time.value;

    final states = <_UnitState>[];
    for (final u in battle.units) {
      final presence = frame.presenceOf(u);
      if (presence <= 0.01) continue;
      final pos = frame.positionOf(u);
      states.add(_UnitState(
        u,
        pos,
        g.map(pos),
        frame.sideOf(u),
        frame.colorOf(u),
        frame.strengthOf(u),
        frame.speedOf(u),
        frame.active(u),
        presence,
        frame.hiddenOf(u),
        frame.stanceOf(u),
        u.type.glyphFor(modern: _modern),
        u.type.weaponFor(modern: _modern),
        figureCount(u, battle),
      ));
    }
    _computeHeadings(states, frame, g);

    if (options.arrows) {
      for (final s in states) {
        _trail(canvas, g, frame, s);
      }
    }
    _casualties(canvas, g, frame, t);
    if (options.arrows) {
      for (final s in states) {
        _arrow(canvas, g, frame, s);
      }
    }
    if (options.effects) {
      for (final s in states) {
        _dust(canvas, g, s, t);
      }
    }
    final ground = states.where((s) => !s.type.isAirborne).toList()..sort((a, b) => a.px.dy.compareTo(b.px.dy));
    for (final s in ground) {
      _formation(canvas, g, s, t);
    }
    if (options.effects) _combat(canvas, g, states, t);
    for (final s in states.where((s) => s.type.isAirborne)) {
      _formation(canvas, g, s, t);
    }
    if (selected != null) {
      for (final s in states) {
        if (identical(s.unit, selected)) _selection(canvas, s, t);
      }
    }
    if (options.badges || options.labels || options.counts) {
      final placed = <Rect>[];
      final order = [...states]..sort((a, b) => b.unit.count.compareTo(a.unit.count));
      for (final s in order) {
        _chip(canvas, g, s, placed);
      }
    }
    if (options.grid) _grid(canvas, g);
  }

  // --- Yo'nalish ---------------------------------------------------------------
  // Harakatda — yo'l bo'ylab, turganda — eng yaqin dushmanga, qochayotganda — dushmandan teskari.

  void _computeHeadings(List<_UnitState> states, BattleFrame frame, MapGeometry g) {
    for (final s in states) {
      _UnitState? enemy;
      var best = double.infinity;
      for (final o in states) {
        if (o.side == s.side || o.strength < 0.05 || o.type.isAirborne) continue;
        final d = (o.px - s.px).distance;
        if (d < best) {
          best = d;
          enemy = o;
        }
      }
      var face = enemy == null ? (s.side == Side.a ? const Offset(-1, 0) : const Offset(1, 0)) : _norm(enemy.px - s.px);
      final dir = frame.moveDirection(s.unit);
      if (dir != null && dir.distance > 0) {
        final m = _norm(g.vec(dir));
        final fleeing = s.stance == Stance.retreat || s.stance == Stance.rout;
        final w = fleeing ? 1.0 : math.min(1.0, s.speed * 1.6);
        face = _norm(face * (1 - w) + m * w);
      }
      s.heading = face;
      s.radius = s.type.isCommand ? g.fig * 3.0 : formationRadius(s.type, s.n, g.fig);
    }
  }

  static Offset _norm(Offset v) => v.distance < 1e-6 ? const Offset(1, 0) : v / v.distance;

  // --- Strelkalar va yo'llar -----------------------------------------------------

  void _trail(Canvas canvas, MapGeometry g, BattleFrame f, _UnitState s) {
    if (f.phase < 2) return;
    final u = s.unit;
    final path = Path();
    var started = false;
    for (var k = 1; k < f.phase; k++) {
      if (!u.presentAt(k - 1)) continue;
      for (final q in MovePath.of(u, k).points) {
        final px = g.map(q);
        if (!started) {
          path.moveTo(px.dx, px.dy);
          started = true;
        } else {
          path.lineTo(px.dx, px.dy);
        }
      }
    }
    if (!started) return;
    dashPath(
        canvas,
        path,
        Paint()
          ..color = s.color.withValues(alpha: 0.45 * s.presence)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
        dash: 5,
        gap: 4);
  }

  /// Harbiy xaritadagi kabi kengayib boruvchi strelka; harakat bilan to'lib boradi.
  /// Yashirin harakat — uzuq-uzuq kontur bilan.
  void _arrow(Canvas canvas, MapGeometry g, BattleFrame f, _UnitState s) {
    if (!f.moves(s.unit)) return;
    final mp = MovePath.of(s.unit, f.phase);
    final len = mp.length * g.s;
    final w = math.min((g.s * 1.1).clamp(3.0, 11.0), len * 0.16);
    final head = math.min(w * 2.6, len * 0.3);
    final endT = (1 - head / len * 0.9).clamp(0.5, 0.97);

    Offset at(double t) => g.map(mp.at(t));
    Offset tan(double t) => _norm(g.vec(mp.tangent(t)));

    Path band(double t0, double t1) {
      const n = 30;
      final left = <Offset>[], right = <Offset>[];
      for (var i = 0; i <= n; i++) {
        final t = t0 + (t1 - t0) * i / n;
        final p = at(t), d = tan(t);
        final nrm = Offset(-d.dy, d.dx);
        final width = w * (0.35 + 0.65 * (t / endT));
        left.add(p + nrm * width / 2);
        right.add(p - nrm * width / 2);
      }
      final path = Path()..moveTo(left.first.dx, left.first.dy);
      for (final q in left.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      for (final q in right.reversed) {
        path.lineTo(q.dx, q.dy);
      }
      return path..close();
    }

    final body = band(0, endT);
    final tip = at(1);
    final base = at(endT);
    final dir = tan(endT);
    final nrm = Offset(-dir.dy, dir.dx);
    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + nrm * head * 0.75).dx, (base + nrm * head * 0.75).dy)
      ..lineTo((base - nrm * head * 0.75).dx, (base - nrm * head * 0.75).dy)
      ..close();

    final color = s.color;
    final a = s.presence;
    final outline = Paint()
      ..color = color.withValues(alpha: 0.65 * a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (s.hidden > 0.5) {
      dashPath(canvas, body, outline, dash: 6, gap: 4);
      dashPath(canvas, headPath, outline, dash: 6, gap: 4);
      return;
    }
    canvas.drawPath(body, Paint()..color = color.withValues(alpha: 0.16 * a));
    canvas.drawPath(headPath, Paint()..color = color.withValues(alpha: 0.16 * a));
    if (f.move > 0) canvas.drawPath(band(0, endT * f.move), Paint()..color = color.withValues(alpha: 0.5 * a));
    if (f.move >= 1) canvas.drawPath(headPath, Paint()..color = color.withValues(alpha: 0.55 * a));
    canvas.drawPath(body, outline);
    canvas.drawPath(headPath, outline);
  }

  // --- Halok bo'lganlar va urilgan texnika ----------------------------------------

  /// Tugallangan bosqichlardagi halok bo'lganlar bir marta chiziladi va keshlanadi —
  /// har kadrda yuzlab figuralarni qayta chizmaslik uchun (animatsiya silliq bo'ladi).
  static final _fallenCache = <String, ui.Picture>{};

  void _casualties(Canvas canvas, MapGeometry g, BattleFrame f, double t) {
    if (f.phase >= 2) {
      final key = '${battle.id}|${f.phase}|${g.size.width.round()}x${g.size.height.round()}';
      var pic = _fallenCache[key];
      if (pic == null) {
        if (_fallenCache.length > 60) _fallenCache.clear();
        final rec = ui.PictureRecorder();
        final c = Canvas(rec);
        for (var j = 1; j < f.phase; j++) {
          _fallenOfPhase(c, g, j, 1);
        }
        pic = _fallenCache[key] = rec.endRecording();
      }
      canvas.drawPicture(pic);
    }
    if (f.phase >= 1 && f.move > 0.02) _fallenOfPhase(canvas, g, f.phase, f.move);
    // Urilgan texnika bir-ikki bosqich yonib turadi.
    if (options.effects) {
      for (var j = math.max(1, f.phase - 1); j <= f.phase; j++) {
        _fires(canvas, g, j, j == f.phase ? f.move : 1, t);
      }
    }
  }

  Iterable<(Unit, Offset, int)> _fallenSpots(MapGeometry g, int j) sync* {
    final max = math.max(1, battle.maxCount);
    for (final u in battle.units) {
      if (u.type.isAirborne) continue;
      final drop = u.strengthAt(j - 1) - u.strengthAt(j);
      if (drop < 0.04) continue;
      final vehicle = u.type.isVehicle;
      final share = u.countsAsSoldiers ? u.count / max : 0.3;
      final n = (drop * share * (vehicle ? 30 : 70)).round().clamp(2, vehicle ? 10 : 26);
      final mp = MovePath.of(u, j);
      final seed = u.label.hashCode % 997 + j * 31;
      for (var i = 0; i < n; i++) {
        final base = g.map(mp.at(0.45 + rand(seed, i, 1) * 0.55));
        final ang = rand(seed, i, 2) * math.pi * 2;
        final r = (0.5 + rand(seed, i, 3) * 3.5) * g.s;
        yield (u, base + Offset(math.cos(ang) * r, math.sin(ang) * r * 0.8), seed + i);
      }
    }
  }

  void _fallenOfPhase(Canvas canvas, MapGeometry g, int j, double alpha) {
    for (final (u, p, seed) in _fallenSpots(g, j)) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      drawFallen(canvas, u.type.glyphFor(modern: _modern), g.fig, battle.colorOf(u.sideAt(j - 1)), seed,
          alpha: alpha, modern: _modern);
      canvas.restore();
      if (_modern && !u.type.isVehicle && seed % 3 == 0) {
        final cp = p + Offset(g.fig * 1.5, g.fig);
        canvas.drawCircle(cp, g.fig * 0.7, Paint()..color = Color.fromRGBO(60, 50, 40, 0.4 * alpha));
      }
    }
  }

  void _fires(Canvas canvas, MapGeometry g, int j, double alpha, double t) {
    if (alpha < 0.05) return;
    for (final (u, p, seed) in _fallenSpots(g, j)) {
      if (!u.type.isVehicle || seed.isOdd) continue;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      drawFire(canvas, g.fig, seed, t, alpha: alpha);
      canvas.restore();
    }
  }

  // --- Saflar ------------------------------------------------------------------------

  void _formation(Canvas canvas, MapGeometry g, _UnitState s, double t) {
    final u = s.unit;
    final type = s.type;
    final fixedCount = type.isCommand || type.isAirborne;
    final alive = fixedCount ? s.n : math.max(s.strength > 0.03 ? 1 : 0, (s.n * s.strength).round());
    if (alive == 0) return;
    final layout = formationLayout(type.formation, s.n);
    final sp = type.figureSpacing * g.fig;
    final fwd = s.heading, lat = Offset(-fwd.dy, fwd.dx);
    final angle = math.atan2(fwd.dy, fwd.dx);

    // Holatga qarab saf: mudofaada zichlashadi, zarbada oldinga cho'ziladi,
    // qochishda tarqalib ketadi.
    final (spread, stretch) = switch (s.stance) {
      Stance.defend => (0.86, 1.0),
      Stance.charge => (0.92, 1.25),
      Stance.retreat => (1.15, 1.0),
      Stance.rout => (1.9, 1.0),
      Stance.surrender => (1.05, 1.0),
      _ => (1.0, 1.0),
    };
    final disorder = 1 + (1 - s.strength) * 0.6;
    final baseAlpha = type.isCommand ? 1.0 : (0.55 + 0.45 * math.min(1, s.strength * 1.5));
    final alpha = s.presence * baseAlpha * (1 - s.hidden * 0.62);
    var color = s.color;
    if (s.stance == Stance.surrender) color = Color.lerp(color, const Color(0xFF9A948A), 0.55)!;
    final charging = s.stance == Stance.charge && s.speed > 0.05;

    var center = s.px;
    if (type.isAirborne) {
      final orbit = type.glyph == Glyph.helicopter || type.glyph == Glyph.drone ? 0.8 : 3.0;
      center += Offset(math.cos(t * 0.9), math.sin(t * 0.9)) * g.fig * orbit;
    }

    final seedBase = u.label.hashCode % 1000;
    for (var i = 0; i < alive; i++) {
      final o = layout[i];
      var local = Offset(o.dx * spread * disorder * stretch, o.dy * spread * disorder);
      var figAngle = angle;
      if (disorder > 1.05 || s.stance == Stance.rout) {
        final amp = (disorder - 1) * 2 + (s.stance == Stance.rout ? 1.6 : 0);
        local += Offset(rand(seedBase, i, 5) - 0.5, rand(seedBase, i, 6) - 0.5) * amp;
      }
      if (s.stance == Stance.rout) figAngle += (rand(seedBase, i, 8) - 0.5) * 1.4;
      if (type.formation == Formation.swarm) {
        final ph = rand(seedBase, i, 7) * math.pi * 2;
        local += Offset(math.cos(t * 1.4 + ph), math.sin(t * 1.4 + ph)) * 0.35;
      } else if (s.speed > 0.05) {
        // Qadam / chopish tebranishi: otliq tezroq va kuchliroq.
        final gallop = type.isMounted ? 14.0 : 9.0;
        final amp = (type.isMounted ? 0.14 : 0.08) * (charging ? 1.6 : 1.0);
        local += Offset(math.sin(t * gallop + i * 1.7) * amp * s.speed, 0);
      } else if (!type.isStatic) {
        local += Offset(math.sin(t * 1.3 + i) * 0.03, 0);
      }
      final p = center + fwd * (local.dx * sp) + lat * (local.dy * sp);

      if (type.isAirborne) {
        canvas.save();
        canvas.translate(p.dx + g.fig * 2.5, p.dy + g.fig * 3.5);
        canvas.rotate(figAngle);
        drawGlyph(canvas, s.glyph, g.fig, Colors.black.withValues(alpha: 0.18 * s.presence), time: t);
        canvas.restore();
      } else if (!type.isStatic) {
        canvas.drawCircle(p + Offset(g.fig * 0.25, g.fig * 0.3), g.fig * (s.glyph == Glyph.elephant ? 1.1 : 0.5),
            Paint()..color = Colors.black.withValues(alpha: 0.2 * alpha));
      }
      canvas.save();
      canvas.translate(p.dx, p.dy);
      if (!type.isCommand) canvas.rotate(figAngle);
      drawGlyph(canvas, s.glyph, type.isCommand ? g.fig * 1.2 : g.fig, color,
          seed: figureSeed(u, i),
          time: t,
          alpha: alpha,
          charging: charging,
          motion: s.speed * (charging ? 1.4 : 1.0),
          royal: kindOf(u, modern: _modern) == 'ruler',
          heading: type.isCommand ? figAngle : 0,
          modern: _modern);
      canvas.restore();

      if (s.stance == Stance.surrender && i % 5 == 0) _whiteFlag(canvas, p, g.fig, t + i, alpha);
    }

    if (s.hidden > 0.05) {
      // Pistirma: uzuq chiziqli halqa.
      dashPath(
          canvas,
          Path()..addOval(Rect.fromCircle(center: center, radius: s.radius + 4)),
          Paint()
            ..color = s.color.withValues(alpha: 0.8 * s.hidden * s.presence)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
          dash: 5,
          gap: 4);
    }
  }

  void _whiteFlag(Canvas canvas, Offset p, double f, double t, double alpha) {
    final top = p + Offset(0, -f * 2.4);
    canvas.drawLine(p, top, Paint()
      ..color = Color.fromRGBO(60, 45, 30, alpha)
      ..strokeWidth = 1);
    final flag = Path()..moveTo(top.dx, top.dy);
    for (var i = 0; i <= 4; i++) {
      flag.lineTo(top.dx + f * 1.3 * i / 4, top.dy + math.sin(t * 5 + i) * f * 0.12 * i / 4);
    }
    for (var i = 4; i >= 0; i--) {
      flag.lineTo(top.dx + f * 1.3 * i / 4, top.dy + f * 0.8 + math.sin(t * 5 + i) * f * 0.12 * i / 4);
    }
    canvas.drawPath(flag..close(), Paint()..color = Colors.white.withValues(alpha: alpha));
  }

  void _dust(Canvas canvas, MapGeometry g, _UnitState s, double t) {
    if (s.speed < 0.08 || s.type.isAirborne || s.type.isCommand || s.type.isStatic || s.hidden > 0.5) return;
    final back = -s.heading;
    final lat = Offset(-s.heading.dy, s.heading.dx);
    if (s.type.domain == Domain.sea) {
      // Kema izi.
      final wake = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * s.speed)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(s.px + back * s.radius, s.px + back * (s.radius * 2.2) + lat * s.radius * 0.6, wake);
      canvas.drawLine(s.px + back * s.radius, s.px + back * (s.radius * 2.2) - lat * s.radius * 0.6, wake);
      return;
    }
    final vehicle = s.type.isVehicle;
    final heavy = s.type.heavy;
    final snowy = battle.biome == Biome.frost || battle.biome == Biome.snow;
    final color = vehicle && _modern
        ? const Color(0xFF6E6A64)
        : (snowy ? const Color(0xFFF5F7F8) : const Color(0xFFC8AE7E));
    final puffs = heavy ? 8 : 4;
    final boost = s.stance == Stance.charge ? 1.5 : 1.0;
    for (var i = 0; i < puffs; i++) {
      final k = (t * 0.8 + i / puffs) % 1.0;
      final side = (rand(i, 3) - 0.5) * s.radius * 1.4;
      final p = s.px + back * (s.radius * 0.8 + k * g.fig * 7 * boost) + lat * side;
      final r = g.fig * (1.2 + k * 2.4) * (heavy ? 1 : 0.7) * boost;
      canvas.drawCircle(p, r, Paint()..color = color.withValues(alpha: 0.28 * (1 - k) * s.speed * s.presence));
    }
  }

  // --- Jang effektlari ---------------------------------------------------------------

  void _combat(Canvas canvas, MapGeometry g, List<_UnitState> states, double t) {
    final drawnMelee = <String>{};
    for (final s in states) {
      if (!s.visibleToEnemy || s.strength < 0.06 || s.weapon == Weapon.none) continue;
      if (s.stance == Stance.surrender || s.stance == Stance.rout) continue;
      final antiAir = s.weapon == Weapon.flak;
      final preferAir = s.weapon == Weapon.strafe;
      _UnitState? target;
      var best = double.infinity;
      for (final o in states) {
        if (o.side == s.side || o.strength < 0.05 || !o.visibleToEnemy) continue;
        if (antiAir && !o.type.isAirborne) continue;
        if (!antiAir && !preferAir && o.type.isAirborne) continue;
        var d = _mapDist(s.pos, o.pos);
        if (preferAir && !o.type.isAirborne) d += 15; // qiruvchi avval samolyotlarga
        if (d < best) {
          best = d;
          target = o;
        }
      }
      if (target == null || !(s.active || target.active)) continue;
      final e = target;
      final k = math.min(1.0, math.min(s.strength, e.strength) * 1.5 + 0.2) * s.presence;
      final dist = _mapDist(s.pos, e.pos);

      // Yaqin jang (ikkala tomon ham quruqlikda).
      if (dist < 9 && !s.type.isAirborne && !e.type.isAirborne && s.type.formation != Formation.battery) {
        final key = s.unit.hashCode < e.unit.hashCode
            ? '${s.unit.hashCode}-${e.unit.hashCode}'
            : '${e.unit.hashCode}-${s.unit.hashCode}';
        if (drawnMelee.add(key)) _melee(canvas, g, s, e, t, k, impact: s.stance == Stance.charge || e.stance == Stance.charge);
        if (s.weapon == Weapon.melee) continue;
      }
      if (s.type.range <= 0 || dist > s.type.range) continue;
      switch (s.weapon) {
        case Weapon.arrows:
          _volley(canvas, g, s, e, t, k, count: 9, speed: 0.9, arc: 0.22, color: const Color(0xFF2B2118));
        case Weapon.bolts:
          _volley(canvas, g, s, e, t, k, count: 6, speed: 1.6, arc: 0.06, color: const Color(0xFF3A2A1A));
        case Weapon.musket:
          _musket(canvas, g, s, e, t, k);
        case Weapon.stones:
          _projectiles(canvas, g, s, e, t, k, count: 2, speed: 0.32, arc: 0.4, size: 0.4,
              color: const Color(0xFF6E6A62), boom: false);
        case Weapon.cannonball:
          _projectiles(canvas, g, s, e, t, k, count: 3, speed: 0.45, arc: 0.28, size: 0.22,
              color: const Color(0xFF222222), smoke: true);
        case Weapon.shells:
          _projectiles(canvas, g, s, e, t, k, count: 3, speed: 0.38, arc: 0.45, size: 0.2,
              color: const Color(0xFF222222), smoke: true, big: true);
        case Weapon.tankGun:
          _tankGun(canvas, g, s, e, t, k);
        case Weapon.rifle:
          _tracers(canvas, g, s, e, t, k, count: 5, speed: 1.8, color: const Color(0xFFFFD166));
        case Weapon.machineGun:
          _tracers(canvas, g, s, e, t, k, count: 10, speed: 3.2, color: const Color(0xFFFFB347));
        case Weapon.rockets:
          _rockets(canvas, g, s, e, t, k);
        case Weapon.bombs:
          _bombs(canvas, g, s, e, t, k);
        case Weapon.strafe:
          _strafe(canvas, g, s, e, t, k);
        case Weapon.flak:
          _flak(canvas, g, s, e, t, k);
        case Weapon.missile:
          _missile(canvas, g, s, e, t, k);
        case Weapon.melee:
        case Weapon.none:
          break;
      }
    }
  }

  double _mapDist(Offset a, Offset b) {
    final dx = a.dx - b.dx, dy = (a.dy - b.dy) * 0.625;
    return math.sqrt(dx * dx + dy * dy);
  }

  Offset _spot(_UnitState u, int i, int salt) =>
      u.px + Offset((rand(i, salt) - 0.5) * u.radius * 1.4, (rand(i, salt + 1) - 0.5) * u.radius);

  Color get _smokeColor => _modern
      ? const Color(0xFF5E5A55)
      : (battle.biome == Biome.frost || battle.biome == Biome.snow ? const Color(0xFFE9EDEF) : const Color(0xFFBFA274));

  void _melee(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k, {bool impact = false}) {
    final c = Offset.lerp(a.px, b.px, a.radius / (a.radius + b.radius + 0.01))!;
    final scale = impact ? 1.5 : 1.0;
    for (var i = 0; i < 6; i++) {
      final ph = (t * 0.5 + i / 6) % 1.0;
      final ang = rand(i, 17) * math.pi * 2;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * g.fig * (1 + ph * 4) * scale;
      canvas.drawCircle(p, g.fig * (1.5 + ph * 3) * scale, Paint()..color = _smokeColor.withValues(alpha: 0.3 * (1 - ph) * k));
    }
    final frameSeed = (t * 14).floor();
    for (var i = 0; i < (impact ? 14 : 8); i++) {
      final ang = rand(frameSeed, i, 1) * math.pi * 2;
      final r = rand(frameSeed, i, 2) * g.fig * 3 * scale;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * r;
      final d = Offset(math.cos(ang + 1), math.sin(ang + 1)) * g.fig * 0.8;
      canvas.drawLine(
          p,
          p + d,
          Paint()
            ..color = (_modern ? const Color(0xFFFFB347) : const Color(0xFFFFF4C2)).withValues(alpha: 0.95 * k)
            ..strokeWidth = 1.3
            ..strokeCap = StrokeCap.round);
    }
  }

  /// Kamon/arbalet o'qlari.
  void _volley(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k,
      {required int count, required double speed, required double arc, required Color color}) {
    final dist = (b.px - a.px).distance;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85 * k)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final ph = (t * speed + i / count) % 1.0;
      final from = _spot(a, i, 5), to = _spot(b, i, 6);
      final h = dist * arc;
      Offset at(double q) => Offset.lerp(from, to, q)! + Offset(0, -4 * h * q * (1 - q));
      final p = at(ph), q = at(math.min(1, ph + 0.04));
      final dir = _norm(q - p);
      canvas.drawLine(p - dir * g.fig * 0.6, p + dir * g.fig * 0.6, paint);
    }
  }

  /// Miltiq zalpi: oldingi qatorda bir vaqtda chaqnash, keyin oq tutun.
  void _musket(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k) {
    final cycle = (t * 0.4 + rand(a.unit.label.hashCode % 100) ) % 1.0;
    final lat = Offset(-a.heading.dy, a.heading.dx);
    final front = a.px + a.heading * a.radius * 0.6;
    const n = 7;
    for (var i = 0; i < n; i++) {
      final along = (i / (n - 1) - 0.5) * a.radius * 1.6;
      final p = front + lat * along;
      if (cycle < 0.08) {
        canvas.drawCircle(p + a.heading * g.fig, g.fig * 0.6, Paint()..color = const Color(0xFFFFE08A).withValues(alpha: k));
      }
      // Tutun: zalpdan keyin kengayib, shamolda suzadi.
      final r = g.fig * (0.8 + cycle * 2.8);
      final drift = Offset(cycle * g.fig * 3, -cycle * g.fig);
      canvas.drawCircle(p + a.heading * g.fig * 1.4 + drift, r,
          Paint()..color = Colors.white.withValues(alpha: 0.5 * (1 - cycle) * k));
    }
    // Nishonda yiqilayotganlar (kichik chang).
    if (cycle < 0.25) {
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(_spot(b, i, 21), g.fig * 0.5, Paint()..color = _smokeColor.withValues(alpha: 0.4 * k));
      }
    }
  }

  /// To'p, gaubitsa, katapulta snaryadlari.
  void _projectiles(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k,
      {required int count,
      required double speed,
      required double arc,
      required double size,
      required Color color,
      bool smoke = false,
      bool big = false,
      bool boom = true}) {
    final dist = (b.px - a.px).distance;
    for (var i = 0; i < count; i++) {
      final ph = (t * speed + i / count) % 1.0;
      final from = _spot(a, i, 30) + a.heading * a.radius * 0.5;
      final to = _spot(b, i, 32);
      if (smoke && ph < 0.18) {
        final q = ph / 0.18;
        canvas.drawCircle(from, g.fig * (0.8 + q * 2.2), Paint()..color = Colors.white.withValues(alpha: 0.6 * (1 - q) * k));
        canvas.drawCircle(from, g.fig * 0.6 * (1 - q), Paint()..color = const Color(0xFFFFC04D).withValues(alpha: k));
      }
      if (ph < 0.85) {
        final q = ph / 0.85;
        final p = Offset.lerp(from, to, q)! + Offset(0, -4 * dist * arc * q * (1 - q));
        canvas.drawCircle(p, math.max(1.2, g.fig * size), Paint()..color = color.withValues(alpha: k));
      } else if (boom) {
        _explosion(canvas, to, g.fig * (big ? 1.5 : 1), (ph - 0.85) / 0.15, k);
      } else {
        final q = (ph - 0.85) / 0.15;
        canvas.drawCircle(to, g.fig * (0.8 + q * 2.5), Paint()..color = _smokeColor.withValues(alpha: 0.55 * (1 - q) * k));
      }
    }
  }

  void _tankGun(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k) {
    for (var i = 0; i < 3; i++) {
      final ph = (t * 0.7 + i / 3) % 1.0;
      final from = _spot(a, i, 40) + a.heading * g.fig * 1.5;
      final to = _spot(b, i, 42);
      if (ph < 0.1) {
        canvas.drawCircle(from, g.fig * 0.9, Paint()..color = const Color(0xFFFFD166).withValues(alpha: k));
      }
      if (ph < 0.3) {
        final p = Offset.lerp(from, to, ph / 0.3)!;
        canvas.drawLine(p, p + _norm(to - from) * g.fig * 2.5,
            Paint()
              ..color = const Color(0xFFFFE8A0).withValues(alpha: k)
              ..strokeWidth = 1.8);
      } else if (ph < 0.55) {
        _explosion(canvas, to, g.fig * 1.1, (ph - 0.3) / 0.25, k);
      }
    }
  }

  void _tracers(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k,
      {required int count, required double speed, required Color color}) {
    for (var i = 0; i < count; i++) {
      final ph = (t * speed + i / count) % 1.0;
      final from = _spot(a, i, 11), to = _spot(b, i, 13);
      final dir = _norm(to - from);
      final p = Offset.lerp(from, to, ph)!;
      canvas.drawLine(p, p + dir * g.fig * 1.8,
          Paint()
            ..color = color.withValues(alpha: 0.9 * k)
            ..strokeWidth = 1.2);
      if (ph > 0.9) canvas.drawCircle(to, g.fig * 0.5, Paint()..color = const Color(0xFFFF9F1C).withValues(alpha: 0.8 * k));
    }
  }

  /// Reaktiv snaryadlar zalpi: tutun izli raketalar va maydon bo'ylab portlashlar.
  void _rockets(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k) {
    final dist = (b.px - a.px).distance;
    const n = 8;
    final cycle = (t * 0.28) % 1.0;
    for (var i = 0; i < n; i++) {
      final ph = cycle - i * 0.03;
      if (ph < 0) continue;
      final from = _spot(a, i, 50), to = _spot(b, i, 52) + Offset((rand(i, 54) - 0.5) * b.radius, 0);
      Offset at(double q) => Offset.lerp(from, to, q)! + Offset(0, -4 * dist * 0.18 * q * (1 - q));
      if (ph < 0.6) {
        final q = ph / 0.6;
        final trail = Path()..moveTo(from.dx, from.dy);
        for (var s = 1; s <= 10; s++) {
          final pt = at(q * s / 10);
          trail.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(
            trail,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.35 * k)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
        canvas.drawCircle(at(q), g.fig * 0.35, Paint()..color = const Color(0xFFFFB347).withValues(alpha: k));
      } else if (ph < 0.85) {
        _explosion(canvas, to, g.fig * 1.2, (ph - 0.6) / 0.25, k);
      }
    }
  }

  void _bombs(Canvas canvas, MapGeometry g, _UnitState plane, _UnitState target, double t, double k) {
    for (var i = 0; i < 4; i++) {
      final ph = (t * 0.7 + i / 4) % 1.0;
      final to = _spot(target, i, 14);
      final from = plane.px + Offset((rand(i, 16) - 0.5) * g.fig * 6, 0);
      if (ph < 0.75) {
        final q = ph / 0.75;
        final p = Offset.lerp(from, to, q * q)!;
        canvas.drawCircle(p, math.max(1.3, g.fig * 0.25), Paint()..color = const Color(0xFF1E1E1E).withValues(alpha: k));
      } else {
        _explosion(canvas, to, g.fig * 1.4, (ph - 0.75) / 0.25, k);
      }
    }
  }

  /// Qiruvchi: nishon ustidan o'tib, qator o'q izlari qoldiradi.
  void _strafe(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k) {
    if (b.type.isAirborne) {
      _tracers(canvas, g, a, b, t, k, count: 6, speed: 2.4, color: const Color(0xFFFFD166));
      return;
    }
    final ph = (t * 0.6) % 1.0;
    final dir = _norm(b.px - a.px);
    final start = b.px - dir * b.radius * 1.2;
    for (var i = 0; i < 10; i++) {
      final q = ph * 1.4 - i * 0.05;
      if (q < 0 || q > 1) continue;
      final p = start + dir * (b.radius * 2.4 * q) + Offset(-dir.dy, dir.dx) * ((i.isEven ? 1 : -1) * g.fig * 0.8);
      canvas.drawCircle(p, g.fig * 0.35, Paint()..color = _smokeColor.withValues(alpha: 0.7 * k));
    }
  }

  /// Zenit: samolyotlar atrofida qora portlash bulutchalari.
  void _flak(Canvas canvas, MapGeometry g, _UnitState gun, _UnitState plane, double t, double k) {
    for (var i = 0; i < 5; i++) {
      final ph = (t * 0.9 + i / 5) % 1.0;
      final c = plane.px + Offset((rand(i, 60) - 0.5) * g.fig * 10, (rand(i, 61) - 0.5) * g.fig * 8);
      if (ph < 0.12) canvas.drawCircle(c, g.fig * 0.5, Paint()..color = const Color(0xFFFFC04D).withValues(alpha: k));
      canvas.drawCircle(c, g.fig * (0.6 + ph * 1.8), Paint()..color = const Color(0xFF2A2A2A).withValues(alpha: 0.55 * (1 - ph) * k));
    }
  }

  /// Boshqariladigan raketa (dron, vertolyot): egri tutun izi va portlash.
  void _missile(Canvas canvas, MapGeometry g, _UnitState a, _UnitState b, double t, double k) {
    final ph = (t * 0.4 + rand(a.unit.label.hashCode % 50)) % 1.0;
    final from = a.px, to = _spot(b, 1, 70);
    final bend = Offset(-(to - from).dy, (to - from).dx) * 0.25;
    Offset at(double q) => bezier(from, (from + to) / 2 + bend, to, q);
    if (ph < 0.7) {
      final q = ph / 0.7;
      final path = Path()..moveTo(from.dx, from.dy);
      for (var s = 1; s <= 14; s++) {
        final pt = at(q * s / 14);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.45 * k)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      canvas.drawCircle(at(q), g.fig * 0.3, Paint()..color = const Color(0xFFFF6B35).withValues(alpha: k));
    } else {
      _explosion(canvas, to, g.fig * 1.2, (ph - 0.7) / 0.3, k);
    }
  }

  void _explosion(Canvas canvas, Offset c, double f, double q, double k) {
    canvas.drawCircle(c, f * (0.8 + q * 3), Paint()..color = const Color(0xFF505050).withValues(alpha: 0.45 * (1 - q) * k));
    canvas.drawCircle(c, f * (0.6 + q * 1.8), Paint()..color = const Color(0xFFFF8C1A).withValues(alpha: 0.85 * (1 - q) * k));
    canvas.drawCircle(c, f * (0.3 + q * 0.8), Paint()..color = const Color(0xFFFFE08A).withValues(alpha: (1 - q) * k));
  }

  // --- Koordinata to'ri ------------------------------------------------------------

  void _grid(Canvas canvas, MapGeometry g) {
    final minor = Paint()
      ..color = const Color(0x552B2118)
      ..strokeWidth = 0.6;
    final major = Paint()
      ..color = const Color(0xAA9E2A2B)
      ..strokeWidth = 1;
    for (var v = 5; v < 100; v += 5) {
      final x = g.size.width * v / 100, y = g.size.height * v / 100;
      final paint = v % 10 == 0 ? major : minor;
      canvas.drawLine(Offset(x, 0), Offset(x, g.size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(g.size.width, y), paint);
      if (v % 10 == 0) {
        final tp = layoutText('$v', fontSize: 10, family: mapCondensed, color: const Color(0xFF9E2A2B),
            weight: FontWeight.w700);
        tp.paint(canvas, Offset(x + 2, 2));
        tp.paint(canvas, Offset(2, y + 1));
      }
    }
  }

  // --- Tanlash va yorliqlar --------------------------------------------------------

  /// Yorliqdagi holat belgisi (faqat muhim holatlar).
  String? _stanceTag(_UnitState s) => switch (s.stance) {
        Stance.hidden => 'yashirin',
        Stance.charge => 'zarba!',
        Stance.rout => 'qochmoqda',
        Stance.surrender => 'taslim',
        _ => null,
      };

  void _selection(Canvas canvas, _UnitState s, double t) {
    final r = s.radius + 8;
    canvas.drawCircle(s.px, r, Paint()..color = Colors.amber.withValues(alpha: 0.14));
    final path = Path()..addOval(Rect.fromCircle(center: s.px, radius: r));
    canvas.save();
    canvas.translate(s.px.dx, s.px.dy);
    canvas.rotate(t * 0.8);
    canvas.translate(-s.px.dx, -s.px.dy);
    dashPath(
        canvas,
        path,
        Paint()
          ..color = Colors.amber.shade700
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
        dash: 7,
        gap: 5);
    canvas.restore();
  }

  /// Bo'linma yorlig'i: tomon rangidagi doirada SVG ikon, yonida nom va askarlar soni.
  void _chip(Canvas canvas, MapGeometry g, _UnitState s, List<Rect> placed) {
    final u = s.unit;
    if (s.strength < 0.03) return;
    final fs = (g.fontSize * 0.95).clamp(9.0, 12.5);
    final count = u.count * (u.type.isCommand || !u.countsAsSoldiers ? 1 : s.strength);
    final countText = u.countUnit == 'askar' ? formatCount(count) : '${formatCount(count)} ${u.countUnit.split(' ').first}';
    final spans = <TextSpan>[
      if (options.labels) TextSpan(text: u.label, style: const TextStyle(color: Color(0xFF1E1A16))),
      if (options.labels && options.counts) const TextSpan(text: '  '),
      if (options.counts)
        TextSpan(text: countText, style: TextStyle(color: Color.lerp(s.color, Colors.black, 0.2), fontWeight: FontWeight.w700)),
      if (options.labels && _stanceTag(s) != null)
        TextSpan(
            text: '  ${_stanceTag(s)}',
            style: const TextStyle(color: Color(0xFF8E3B2E), fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
    ];
    final hasText = spans.isNotEmpty;
    final tp = TextPainter(
      text: TextSpan(
          style: TextStyle(fontFamily: mapCondensed, fontSize: fs, height: 1.1, fontWeight: FontWeight.w500),
          children: spans),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final badge = options.badges ? (fs * 2.3).clamp(20.0, 30.0) : 0.0;
    final h = math.max(tp.height + 6, badge);
    final w = hasText ? tp.width + badge + (badge > 0 ? 8 : 10) + 4 : badge;
    // Boshqa yorliqlar bilan ustma-ust tushmaydigan joyni qidiramiz: pastda, tepada, yonlarda.
    final below = s.px.dy + s.radius + 3, above = s.px.dy - s.radius - h - 3;
    final candidates = <Offset>[
      Offset(s.px.dx - w / 2, below),
      Offset(s.px.dx - w / 2, above),
      Offset(s.px.dx + s.radius + 4, s.px.dy - h / 2),
      Offset(s.px.dx - s.radius - 4 - w, s.px.dy - h / 2),
      Offset(s.px.dx - w / 2, below + h + 2),
      Offset(s.px.dx - w / 2, above - h - 2),
    ];
    Rect fit(Offset o) => Rect.fromLTWH(o.dx.clamp(4.0, math.max(4.0, g.size.width - w - 4)),
        o.dy.clamp(4.0, math.max(4.0, g.size.height - h - 4)), w, h);
    var rect = fit(candidates.first);
    for (final c in candidates) {
      final r = fit(c);
      if (!placed.any((p) => p.overlaps(r.inflate(1)))) {
        rect = r;
        break;
      }
    }
    placed.add(rect);
    final opacity = (0.55 + 0.45 * math.min(1, s.strength * 1.4)) * s.presence * (1 - s.hidden * 0.4);

    if (hasText) {
      final pill = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));
      canvas.drawRRect(pill.shift(const Offset(0, 1)), Paint()..color = Colors.black.withValues(alpha: 0.2 * opacity));
      canvas.drawRRect(pill, Paint()..color = const Color(0xFFFFFBF2).withValues(alpha: 0.92 * opacity));
      canvas.saveLayer(rect, Paint()..color = Colors.black.withValues(alpha: opacity));
      tp.paint(canvas, Offset(rect.left + (badge > 0 ? badge + 6 : 8), rect.top + (h - tp.height) / 2));
      canvas.restore();
    }
    if (badge > 0) {
      final c = Offset(rect.left + badge / 2, rect.top + h / 2);
      _badge(canvas, c, badge, kindOf(u, modern: battle.modern), s.color, opacity, u.type);
    }
  }

  void _badge(Canvas canvas, Offset c, double size, String kind, Color color, double opacity, UnitType type) {
    final r = size / 2;
    canvas.drawCircle(c + const Offset(0, 1), r, Paint()..color = Colors.black.withValues(alpha: 0.25 * opacity));
    canvas.drawCircle(c, r, Paint()..color = color.withValues(alpha: opacity));
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFFFFBF2).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    if (kind == 'ruler') {
      // Hukmdor belgisi — oltin halqa.
      canvas.drawCircle(
          c,
          r + 2,
          Paint()
            ..color = const Color(0xFFD9B45A).withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2);
    }
    final img = UnitCatalog.image(kind);
    final inner = Rect.fromCircle(center: c, radius: r * 0.66);
    if (img != null) {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        inner,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: opacity), BlendMode.srcIn),
      );
    } else {
      // Ikon hali yuklanmagan bo'lsa — NATO belgisi.
      paintNatoSymbol(canvas, c, Size(r * 1.3, r * 0.9), type, color, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(UnitsPainter old) =>
      old.battle != battle || old.selected != selected || old.options != options || old.progress != progress;
}
