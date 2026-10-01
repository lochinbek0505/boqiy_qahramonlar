import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models.dart';
import '../widgets/battle_hud.dart';
import 'frame.dart';
import 'terrain_image.dart';
import 'terrain_painter.dart';
import 'units_painter.dart';

/// Toza jang xaritasi: landshaft, qo'shinlar, effektlar va raqamli voqea belgilari.
/// Ustida hech qanday kartochka yo'q — sarlavha va izohlar xaritadan tashqarida
/// ([BattleHeader], [EventsStrip]) ko'rsatiladi.
class BattleMap extends StatefulWidget {
  const BattleMap({
    super.key,
    required this.battle,
    required this.progress,
    this.options = const ViewOptions(),
    this.selected,
    this.onUnitTap,
    this.onCoordinate,
    this.interactive = true,
  });

  final Battle battle;
  final ValueListenable<double> progress;
  final ViewOptions options;
  final Unit? selected;
  final ValueChanged<Unit?>? onUnitTap;

  /// Koordinata rejimida (options.grid) bosilgan nuqta 0..100 koordinatalarda.
  final ValueChanged<Offset>? onCoordinate;

  /// false — bosh sahifadagi statik kichik ko'rinish.
  final bool interactive;

  @override
  State<BattleMap> createState() => _BattleMapState();
}

class _BattleMapState extends State<BattleMap> with SingleTickerProviderStateMixin {
  final _time = ValueNotifier<double>(0);
  Ticker? _ticker;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadTerrain();
    if (widget.interactive) {
      _ticker = createTicker((elapsed) => _time.value = elapsed.inMicroseconds / 1e6)..start();
    }
  }

  void _loadTerrain() {
    _image = TerrainImages.ready(widget.battle);
    if (_image != null) return;
    TerrainImages.load(widget.battle).then((img) {
      if (mounted) setState(() => _image = img);
    });
  }

  @override
  void didUpdateWidget(BattleMap old) {
    super.didUpdateWidget(old);
    if (old.battle != widget.battle) _loadTerrain();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _time.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails d, Size size) {
    final g = MapGeometry(size);
    if (widget.options.grid && widget.onCoordinate != null) {
      widget.onCoordinate!(g.unmap(d.localPosition));
      return;
    }
    final frame = BattleFrame(widget.battle, widget.progress.value);
    Unit? best;
    var bestDist = double.infinity;
    for (final u in widget.battle.units) {
      if (frame.presenceOf(u) < 0.3) continue;
      final dist = (g.map(frame.positionOf(u)) - d.localPosition).distance;
      if (dist < bestDist) {
        bestDist = dist;
        best = u;
      }
    }
    widget.onUnitTap?.call(bestDist < 40 ? best : null);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.battle;
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = c.biggest;
          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(painter: TerrainPainter(b, _image, compact: !widget.interactive)),
              ),
              GestureDetector(
                onTapUp: widget.interactive ? (d) => _handleTap(d, size) : null,
                // Bo'linmalar har kadrda qayta chiziladi — RepaintBoundary bu
                // chizishni sahifaning qolgan qismiga (panel, tugmalar) yoymaydi.
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: UnitsPainter(
                      battle: b,
                      progress: widget.progress,
                      time: _time,
                      options: widget.interactive
                          ? widget.options
                          : const ViewOptions(labels: false, counts: false, effects: false, badges: false),
                      selected: widget.selected,
                    ),
                  ),
                ),
              ),
              if (widget.interactive)
                RepaintBoundary(
                  child: _NoteMarkers(battle: b, progress: widget.progress, size: size),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Joriy bosqich voqealari joyida faqat kichik raqamli pulsatsiyalanuvchi belgi.
/// Matnlar xaritadan tashqarida — [EventsStrip] da, xuddi shu raqamlar bilan.
class _NoteMarkers extends StatefulWidget {
  const _NoteMarkers({required this.battle, required this.progress, required this.size});
  final Battle battle;
  final ValueListenable<double> progress;
  final Size size;

  @override
  State<_NoteMarkers> createState() => _NoteMarkersState();
}

class _NoteMarkersState extends State<_NoteMarkers> {
  late int _phase = BattleFrame(widget.battle, widget.progress.value).phase;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
  }

  @override
  void didUpdateWidget(_NoteMarkers old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      old.progress.removeListener(_onProgress);
      widget.progress.addListener(_onProgress);
    }
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  void _onProgress() {
    final p = BattleFrame(widget.battle, widget.progress.value).phase;
    if (p != _phase) setState(() => _phase = p);
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.battle.phases[_phase].notes;
    const dot = 22.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < notes.length; i++)
          Positioned(
            key: ValueKey('$_phase-$i'),
            left: (notes[i].pos.dx / 100 * widget.size.width - dot / 2).clamp(0, widget.size.width - dot),
            top: (notes[i].pos.dy / 100 * widget.size.height - dot / 2).clamp(0, widget.size.height - dot),
            child: IgnorePointer(
              child: NoteNumber(index: i, kind: notes[i].kind, size: dot, pulse: true)
                  .animate(delay: (250 + i * 300).ms)
                  .fadeIn(duration: 300.ms)
                  .scaleXY(begin: 0.3, end: 1, duration: 400.ms, curve: Curves.easeOutBack),
            ),
          ),
      ],
    );
  }
}
