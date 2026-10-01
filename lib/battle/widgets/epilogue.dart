import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/unit_catalog.dart';
import '../map/frame.dart';
import '../models.dart';

/// Bir tomonning jang yakunidagi hisobi (xarita ma'lumotlari bo'yicha).
class SideOutcome {
  const SideOutcome({
    required this.side,
    required this.start,
    required this.lost,
    required this.defected,
    required this.left,
  });

  final Side side;

  /// Jangda qatnashgan askarlar (shu tomonda boshlaganlar).
  final int start;

  /// Halok bo'lgan, yarador yoki asirga tushganlar.
  final int lost;

  /// Raqib tomoniga o'tib ketganlar.
  final int defected;

  /// Maydondan chiqib ketganlar (evakuatsiya, orqaga chekinish).
  final int left;

  int get remaining => math.max(0, start - lost - defected - left);
  double get lostShare => start == 0 ? 0 : lost / start;
}

class BattleOutcome {
  BattleOutcome._(this.battle, this.sides);

  factory BattleOutcome.of(Battle b) {
    final last = b.phases.length - 1;
    SideOutcome calc(Side side) {
      var start = 0.0, lost = 0.0, defected = 0.0, left = 0.0;
      for (final u in b.units) {
        if (!u.countsAsSoldiers || u.sideAt(u.appearAt ?? 0) != side) continue;
        final end = u.strengthAt(last);
        start += u.count;
        lost += u.count * (1 - end);
        if (u.defectAt != null) {
          defected += u.count * end;
        } else if (u.leaveAt != null) {
          left += u.count * end;
        }
      }
      return SideOutcome(side: side, start: start.round(), lost: lost.round(), defected: defected.round(), left: left.round());
    }

    return BattleOutcome._(b, {for (final s in Side.values) s: calc(s)});
  }

  final Battle battle;
  final Map<Side, SideOutcome> sides;

  Side get winner => battle.winner;
  Side get loser => winner == Side.a ? Side.b : Side.a;
}

/// Jang yakuni: g'olib, yo'qotishlar (sanoq animatsiyasi bilan) va tarixiy oqibatlar.
class EpilogueOverlay extends StatelessWidget {
  const EpilogueOverlay({super.key, required this.battle, required this.onReplay, required this.onClose, this.onExport});

  final Battle battle;
  final VoidCallback onReplay;
  final VoidCallback onClose;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final o = BattleOutcome.of(battle);
    final win = battle.colorOf(o.winner);
    final text = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Orqa fon: xira va biroz xiralashtirilgan (jang maydoni orqada ko'rinib turadi).
        GestureDetector(
          onTap: onClose,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: const ColoredBox(color: Color(0xAA0E0B08)),
          ),
        ).animate().fadeIn(duration: 500.ms),
        const _Sparks().animate().fadeIn(duration: 800.ms),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: const Color(0xFFFBF7EE),
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                elevation: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // G'olib sarlavhasi.
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.lerp(win, Colors.black, 0.35)!, win],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x33FFFFFF),
                              border: Border.all(color: const Color(0xFFE0B25B), width: 2.5),
                            ),
                            child: const KindIcon('rally_point', color: Color(0xFFFFF4D6)),
                          )
                              .animate()
                              .scaleXY(begin: 0.2, end: 1, duration: 700.ms, curve: Curves.elasticOut)
                              .then()
                              .shimmer(duration: 1200.ms, color: const Color(0xFFE0B25B)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('JANG YAKUNI',
                                    style: TextStyle(color: Color(0xCCFFF4D6), letterSpacing: 2, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('G\'alaba: ${battle.nameOf(o.winner)}',
                                        style: text.headlineSmall?.copyWith(
                                            color: Colors.white, fontFamily: mapSerif, fontWeight: FontWeight.w700))
                                    .animate()
                                    .fadeIn(delay: 250.ms, duration: 500.ms)
                                    .slideX(begin: 0.1, end: 0),
                                const SizedBox(height: 4),
                                Text(battle.facts.result, style: const TextStyle(color: Color(0xE6FFFFFF), height: 1.35))
                                    .animate()
                                    .fadeIn(delay: 500.ms, duration: 500.ms),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, side) in [o.winner, o.loser].indexed)
                            _SideResult(battle: battle, r: o.sides[side]!, winner: side == o.winner, delay: 700 + i * 500),
                          const SizedBox(height: 6),
                          const Text(
                            'Raqamlar xaritadagi ma\'lumotlar bo\'yicha taxminiy. Tarixiy baholar — «Ma\'lumot» bo\'limida.',
                            style: TextStyle(fontSize: 11.5, color: Colors.black45),
                          ),
                          if (battle.aftermath.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text('JANGDAN KEYIN',
                                style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(battle.aftermath, style: const TextStyle(fontFamily: mapSerif, fontSize: 15.5, height: 1.5))
                                .animate()
                                .fadeIn(delay: 1900.ms, duration: 700.ms),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          TextButton(onPressed: onClose, child: const Text('Yopish')),
                          OutlinedButton.icon(onPressed: onReplay, icon: const Icon(Icons.replay), label: const Text('Qayta ko\'rish')),
                          if (onExport != null)
                            FilledButton.icon(
                              onPressed: onExport,
                              icon: const Icon(Icons.movie_creation_outlined),
                              label: const Text('Videoga yuklab olish'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.92, end: 1, curve: Curves.easeOutBack),
          ),
        ),
      ],
    );
  }
}

class _SideResult extends StatelessWidget {
  const _SideResult({required this.battle, required this.r, required this.winner, required this.delay});
  final Battle battle;
  final SideOutcome r;
  final bool winner;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final color = battle.colorOf(r.side);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1600),
        curve: Interval(delay / 3200, 1, curve: Curves.easeOutCubic),
        builder: (context, t, _) {
          final shown = (r.start - (r.start - r.remaining) * t).round();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(battle.nameOf(r.side),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                  ),
                  if (winner)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.emoji_events, color: Color(0xFFC99A3B), size: 20),
                    ),
                  Text(formatCount(shown), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                  Text(' / ${formatCount(r.start)}', style: const TextStyle(color: Colors.black45)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 12,
                  child: Stack(fit: StackFit.expand, children: [
                    ColoredBox(color: color.withValues(alpha: 0.15)),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: r.start == 0 ? 0 : (shown / r.start).clamp(0.0, 1.0),
                      child: ColoredBox(color: color),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 14,
                children: [
                  _Stat('Halok, yarador, asir', r.lost, t, const Color(0xFF9E2A2B)),
                  if (r.defected > 0) _Stat('Tomon o\'zgartirdi', r.defected, t, const Color(0xFF8E44AD)),
                  if (r.left > 0) _Stat('Maydondan chiqdi', r.left, t, const Color(0xFF3D5A80)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.t, this.color);
  final String label;
  final int value;
  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(children: [
        TextSpan(text: '$label: ', style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
        TextSpan(
            text: '~${formatCount((value * t).round())}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ]));
}

/// Yakun fonida sekin ko'tariladigan oltin uchqunlar.
class _Sparks extends StatefulWidget {
  const _Sparks();

  @override
  State<_Sparks> createState() => _SparksState();
}

class _SparksState extends State<_Sparks> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(painter: _SparksPainter(_c.value)),
        ),
      );
}

class _SparksPainter extends CustomPainter {
  _SparksPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 40; i++) {
      final k = (t + rand(i, 1)) % 1.0;
      final x = rand(i, 2) * size.width + math.sin((t * 6 + i) * 1.3) * 12;
      final y = size.height * (1 - k);
      canvas.drawCircle(Offset(x, y), 1.2 + rand(i, 3) * 2.2,
          Paint()..color = const Color(0xFFE0B25B).withValues(alpha: 0.55 * math.sin(k * math.pi)));
    }
  }

  @override
  bool shouldRepaint(_SparksPainter old) => old.t != t;
}
