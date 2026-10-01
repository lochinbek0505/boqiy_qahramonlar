import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/unit_catalog.dart';
import '../map/battle_map.dart';
import '../map/figures.dart';
import '../map/frame.dart';
import '../map/units_painter.dart';
import '../models.dart';
import '../platform/fullscreen.dart';
import '../video/export_dialog.dart';
import '../widgets/battle_hud.dart';
import '../widgets/epilogue.dart';
import '../widgets/force_bar.dart';

/// Bir bosqich 1x tezlikda qancha davom etadi.
const _phaseDuration = Duration(milliseconds: 10000);

enum _Tab { course, forces, info }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.battle, this.initialProgress, this.initialFullscreen = false});
  final Battle battle;

  /// Berilsa, animatsiya shu nuqtada to'xtagan holda ochiladi.
  final double? initialProgress;

  /// Havoladan ochilganda ilova ichidagi to'liq ekran rejimi (brauzer rejimi foydalanuvchi bosganda yoqiladi).
  final bool initialFullscreen;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _speed = 1;
  Unit? _selected;
  int _phase = 0;
  _Tab _tab = _Tab.course;
  ViewOptions _options = const ViewOptions();
  late bool _fullscreen = widget.initialFullscreen;

  /// Har bosqich oxirida avtomatik to'xtash — o'qib, tushunib olish uchun.
  bool _autoPause = false;

  /// Jang oxirigacha ko'rilgandan so'ng yakun (jang taqdiri) ko'rsatiladi.
  bool _showEpilogue = false;
  void Function()? _unsubscribeFullscreen;

  Battle get battle => widget.battle;
  int get _phaseCount => battle.phases.length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      upperBound: _phaseCount.toDouble(),
      duration: _phaseDuration * _phaseCount,
    )
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
    // Foydalanuvchi brauzerda Esc bosib chiqsa, ilova ham oddiy ko'rinishga qaytadi.
    _unsubscribeFullscreen = onBrowserFullscreenChange((fs) {
      if (!fs && _fullscreen && mounted) setState(() => _fullscreen = false);
    });
    if (widget.initialProgress != null) {
      _ctrl.value = widget.initialProgress!.clamp(0, _phaseCount).toDouble();
      _phase = BattleFrame(battle, _ctrl.value).phase;
      // Havola jang oxiriga ko'rsatsa (masalan, ?t=6) — yakun darhol ochiladi.
      _showEpilogue = _ctrl.value >= _phaseCount;
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  Future<void> _setFullscreen(bool value) async {
    if (value == _fullscreen) return;
    setState(() => _fullscreen = value);
    if (value) {
      await enterBrowserFullscreen();
    } else {
      await exitBrowserFullscreen();
    }
  }

  void _onTick() {
    final p = BattleFrame(battle, _ctrl.value).phase;
    if (p != _phase) setState(() => _phase = p);
  }

  @override
  void dispose() {
    _unsubscribeFullscreen?.call();
    if (_fullscreen) exitBrowserFullscreen();
    _ctrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl.isAnimating) {
      _ctrl.stop();
      setState(() {});
    } else {
      _play();
    }
  }

  void _play() {
    if (_ctrl.value >= _phaseCount - 0.001) _ctrl.value = 0;
    _showEpilogue = false;
    if (_autoPause) {
      // Keyingi bosqich chegarasigacha o'ynab, to'xtaydi.
      final target = (_ctrl.value + 0.001).floorToDouble() + 1;
      final remain = target - _ctrl.value;
      _ctrl.animateTo(target.clamp(0, _phaseCount.toDouble()), duration: _phaseDuration * (remain / _speed));
    } else {
      _ctrl.forward();
    }
    setState(() {});
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _ctrl.value >= _phaseCount - 0.001) {
      // Jang tugadi — yakunni ko'rsatamiz.
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !_ctrl.isAnimating && _ctrl.value >= _phaseCount - 0.001) {
          setState(() => _showEpilogue = true);
        }
      });
    }
    setState(() {});
  }

  void _goToPhase(int i) {
    final k = i.clamp(0, _phaseCount - 1);
    _ctrl.stop();
    _showEpilogue = false;
    _ctrl.value = k.toDouble();
    _ctrl.animateTo(k + 0.999, duration: _phaseDuration * (1 / _speed));
    setState(() {});
  }

  void _setSpeed(double s) {
    final playing = _ctrl.isAnimating;
    _speed = s;
    _ctrl.stop();
    _ctrl.duration = _phaseDuration * (_phaseCount / s);
    if (playing) {
      _play();
    } else {
      setState(() {});
    }
  }

  /// Koordinata rejimi: bosilgan joyni `p(x, y)` ko'rinishida nusxalaydi — yangi jang yozishda qulay.
  void _showCoordinate(Offset o) {
    final text = 'p(${o.dx.round()}, ${o.dy.round()})';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('$text — nusxalandi (${_phase + 1}-bosqich)'),
      ));
  }

  void _openExport() {
    _ctrl.stop();
    setState(() {});
    showVideoExportDialog(context, battle, _options);
  }

  void _select(Unit? u) => setState(() => _selected = identical(u, _selected) ? null : u);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
      const SingleActivator(LogicalKeyboardKey.arrowRight): () => _goToPhase(_phase + 1),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goToPhase(_phase - 1),
      const SingleActivator(LogicalKeyboardKey.keyF): () => _setFullscreen(!_fullscreen),
      const SingleActivator(LogicalKeyboardKey.escape): () => _setFullscreen(false),
    };
    final fsButton = IconButton.filledTonal(
      tooltip: _fullscreen ? 'To\'liq ekrandan chiqish (Esc)' : 'To\'liq ekran (F)',
      onPressed: () => _setFullscreen(!_fullscreen),
      icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
    );
    final exportButton = IconButton.filledTonal(
      tooltip: 'Videoga eksport',
      onPressed: _openExport,
      icon: const Icon(Icons.movie_creation_outlined),
    );
    final header = BattleHeader(
      battle: battle,
      progress: _ctrl,
      dark: _fullscreen,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [exportButton, const SizedBox(width: 6), fsButton]),
    );
    final events = EventsStrip(battle: battle, phase: _phase, dark: _fullscreen);

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BattleMap(
        battle: battle,
        progress: _ctrl,
        options: _options,
        selected: _selected,
        onUnitTap: _select,
        onCoordinate: _showCoordinate,
      ),
    );
    final controls = _Controls(
      dark: _fullscreen,
      ctrl: _ctrl,
      phaseCount: _phaseCount,
      speed: _speed,
      onPlay: _togglePlay,
      onPrev: () => _goToPhase(_phase - 1),
      onNext: () => _goToPhase(_phase + 1),
      onRestart: () => _goToPhase(0),
      onSpeed: _setSpeed,
      options: _options,
      onOptions: (o) => setState(() => _options = o),
      autoPause: _autoPause,
      onAutoPause: (v) => setState(() => _autoPause = v),
      onPhaseTap: _goToPhase,
      battle: battle,
    );
    final panel = _Panel(
      battle: battle,
      ctrl: _ctrl,
      phase: _phase,
      tab: _tab,
      onTab: (t) => setState(() => _tab = t),
      selected: _selected,
      onSelect: _select,
      onPhaseTap: _goToPhase,
    );

    final Widget body;
    if (_fullscreen) {
      // To'liq ekran: faqat xarita va uning atrofidagi ixcham boshqaruv. Xarita ustida hech narsa yo'q.
      body = ColoredBox(
        color: const Color(0xFF17120D),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(
              children: [
                header,
                const SizedBox(height: 8),
                Expanded(child: Center(child: map)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: events),
                controls,
              ],
            ),
          ),
        ),
      );
    } else {
      final mapColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 10),
          map,
          const SizedBox(height: 10),
          events,
          const SizedBox(height: 4),
          controls,
        ],
      );
      body = wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: mapColumn)),
                SizedBox(
                  width: 420,
                  child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(0, 16, 16, 24), child: panel),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [mapColumn, const SizedBox(height: 8), panel],
            );
    }

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: _fullscreen
              ? null
              : AppBar(
                  leading: IconButton(
                    tooltip: 'Janglar',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/battles'),
                  ),
                  title: Text('${battle.name} · ${battle.date}', overflow: TextOverflow.ellipsis),
                  actions: [
                    IconButton(
                      tooltip: 'Qo\'shin turlari lug\'ati',
                      icon: const Icon(Icons.menu_book),
                      onPressed: () => context.push('/battles/types'),
                    ),
                  ],
                ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              body,
              if (_showEpilogue)
                EpilogueOverlay(
                  battle: battle,
                  onClose: () => setState(() => _showEpilogue = false),
                  onReplay: () {
                    setState(() => _showEpilogue = false);
                    _ctrl.value = 0;
                    _play();
                  },
                  onExport: () {
                    setState(() => _showEpilogue = false);
                    _openExport();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Boshqaruv paneli
// ---------------------------------------------------------------------------

class _Controls extends StatelessWidget {
  const _Controls({
    required this.dark,
    required this.ctrl,
    required this.phaseCount,
    required this.speed,
    required this.onPlay,
    required this.onPrev,
    required this.onNext,
    required this.onRestart,
    required this.onSpeed,
    required this.options,
    required this.onOptions,
    required this.autoPause,
    required this.onAutoPause,
    required this.onPhaseTap,
    required this.battle,
  });

  final bool dark;
  final AnimationController ctrl;
  final int phaseCount;
  final double speed;
  final VoidCallback onPlay, onPrev, onNext, onRestart;
  final ValueChanged<double> onSpeed;
  final ViewOptions options;
  final ValueChanged<ViewOptions> onOptions;
  final bool autoPause;
  final ValueChanged<bool> onAutoPause;
  final ValueChanged<int> onPhaseTap;
  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final playing = ctrl.isAnimating;
    if (dark) return _compact(context, playing);
    final column = Column(
      children: [
        AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) => SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 5),
            child: Slider(
              value: ctrl.value.clamp(0, phaseCount.toDouble()),
              max: phaseCount.toDouble(),
              divisions: phaseCount * 60,
              onChanged: (v) {
                ctrl.stop();
                ctrl.value = v;
              },
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 6,
          children: [
            IconButton(tooltip: 'Boshidan', onPressed: onRestart, icon: const Icon(Icons.replay)),
            IconButton(tooltip: 'Oldingi bosqich (←)', onPressed: onPrev, icon: const Icon(Icons.skip_previous)),
            FilledButton.icon(
              onPressed: onPlay,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              label: Text(playing ? 'To\'xtatish' : 'Boshlash'),
            ),
            IconButton(tooltip: 'Keyingi bosqich (→)', onPressed: onNext, icon: const Icon(Icons.skip_next)),
            const SizedBox(width: 8),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.5, label: Text('0.5x')),
                ButtonSegment(value: 1, label: Text('1x')),
                ButtonSegment(value: 2, label: Text('2x')),
              ],
              selected: {speed},
              showSelectedIcon: false,
              onSelectionChanged: (s) => onSpeed(s.first),
            ),
          ],
        ),
        const SizedBox(height: 4),
        PhaseTimeline(battle: battle, progress: ctrl, onPhaseTap: onPhaseTap),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _Toggle('Har bosqichdan keyin to\'xtash', Icons.pause_circle_outline, autoPause, onAutoPause),
            _Toggle('Nomlar', Icons.label_outline, options.labels, (v) => onOptions(options.copyWith(labels: v))),
            _Toggle('Askarlar soni', Icons.groups_outlined, options.counts,
                (v) => onOptions(options.copyWith(counts: v))),
            _Toggle('Strelkalar', Icons.trending_flat, options.arrows, (v) => onOptions(options.copyWith(arrows: v))),
            _Toggle('Jang effektlari', Icons.local_fire_department_outlined, options.effects,
                (v) => onOptions(options.copyWith(effects: v))),
            _Toggle('Tur ikonlari', Icons.shield_outlined, options.badges,
                (v) => onOptions(options.copyWith(badges: v))),
            _Toggle('Koordinatalar', Icons.grid_4x4, options.grid, (v) => onOptions(options.copyWith(grid: v))),
          ],
        ),
      ],
    );
    return column;
  }

  /// To'liq ekran uchun bitta qatordagi ixcham boshqaruv — xaritaga ko'proq joy qoladi.
  Widget _compact(BuildContext context, bool playing) {
    const fg = Color(0xFFF3E6CC);
    final toggles = <(String, bool, ViewOptions Function(bool))>[
      ('Nomlar', options.labels, (v) => options.copyWith(labels: v)),
      ('Askarlar soni', options.counts, (v) => options.copyWith(counts: v)),
      ('Strelkalar', options.arrows, (v) => options.copyWith(arrows: v)),
      ('Jang effektlari', options.effects, (v) => options.copyWith(effects: v)),
      ('Tur ikonlari', options.badges, (v) => options.copyWith(badges: v)),
      ('Koordinatalar', options.grid, (v) => options.copyWith(grid: v)),
    ];
    return IconTheme(
      data: const IconThemeData(color: fg),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        PhaseTimeline(battle: battle, progress: ctrl, onPhaseTap: onPhaseTap, dark: true),
        Row(
        children: [
          IconButton(tooltip: 'Boshidan', onPressed: onRestart, icon: const Icon(Icons.replay)),
          IconButton(tooltip: 'Oldingi bosqich (←)', onPressed: onPrev, icon: const Icon(Icons.skip_previous)),
          IconButton.filled(
            tooltip: playing ? 'To\'xtatish (probel)' : 'Boshlash (probel)',
            onPressed: onPlay,
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(tooltip: 'Keyingi bosqich (→)', onPressed: onNext, icon: const Icon(Icons.skip_next)),
          Expanded(
            child: AnimatedBuilder(
              animation: ctrl,
              builder: (context, _) => Slider(
                value: ctrl.value.clamp(0, phaseCount.toDouble()),
                max: phaseCount.toDouble(),
                divisions: phaseCount * 60,
                onChanged: (v) {
                  ctrl.stop();
                  ctrl.value = v;
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () => onSpeed(speed == 0.5 ? 1 : (speed == 1 ? 2 : 0.5)),
            child: Text('${speed == 0.5 ? '0.5' : speed.toInt()}x',
                style: const TextStyle(color: fg, fontWeight: FontWeight.w700)),
          ),
          PopupMenuButton<int>(
            tooltip: 'Ko\'rinish',
            icon: const Icon(Icons.layers_outlined),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(value: -1, checked: autoPause, child: const Text('Har bosqichdan keyin to\'xtash')),
              const PopupMenuDivider(),
              for (var i = 0; i < toggles.length; i++)
                CheckedPopupMenuItem(value: i, checked: toggles[i].$2, child: Text(toggles[i].$1)),
            ],
            onSelected: (i) => i == -1 ? onAutoPause(!autoPause) : onOptions(toggles[i].$3(!toggles[i].$2)),
          ),
        ],
      ),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(this.label, this.icon, this.value, this.onChanged);
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => FilterChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: value,
        showCheckmark: false,
        onSelected: onChanged,
      );
}

// ---------------------------------------------------------------------------
// Yon panel
// ---------------------------------------------------------------------------

class _Panel extends StatelessWidget {
  const _Panel({
    required this.battle,
    required this.ctrl,
    required this.phase,
    required this.tab,
    required this.onTab,
    required this.selected,
    required this.onSelect,
    required this.onPhaseTap,
  });

  final Battle battle;
  final AnimationController ctrl;
  final int phase;
  final _Tab tab;
  final ValueChanged<_Tab> onTab;
  final Unit? selected;
  final ValueChanged<Unit?> onSelect;
  final ValueChanged<int> onPhaseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PhaseCard(battle: battle, phase: phase),
        if (selected != null) _SelectedUnit(battle: battle, unit: selected!, ctrl: ctrl, onClose: () => onSelect(null)),
        const SizedBox(height: 4),
        SegmentedButton<_Tab>(
          segments: const [
            ButtonSegment(value: _Tab.course, icon: Icon(Icons.timeline), label: Text('Jang borishi')),
            ButtonSegment(value: _Tab.forces, icon: Icon(Icons.groups), label: Text('Kuchlar')),
            ButtonSegment(value: _Tab.info, icon: Icon(Icons.menu_book_outlined), label: Text('Ma\'lumot')),
          ],
          selected: {tab},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onTab(s.first),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: switch (tab) {
              _Tab.course => _CourseTab(battle: battle, phase: phase, onPhaseTap: onPhaseTap),
              _Tab.forces => _ForcesTab(battle: battle, ctrl: ctrl, onSelect: onSelect, selected: selected),
              _Tab.info => _InfoTab(battle: battle),
            },
          ),
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.battle, required this.phase});
  final Battle battle;
  final int phase;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final current = battle.phases[phase];
    return Card(
      color: const Color(0xFF2B2118),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          key: ValueKey(phase),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${phase + 1}-bosqich / ${battle.phases.length}',
                style: text.labelMedium?.copyWith(color: const Color(0xFFD9C8A8), letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(current.title, style: text.titleLarge?.copyWith(color: const Color(0xFFF3E6CC))),
            const SizedBox(height: 8),
            Text(current.text,
                style: text.bodyMedium?.copyWith(color: const Color(0xFFEDE3D0), height: 1.45, fontSize: 15)),
          ],
        ).animate(key: ValueKey(phase)).fadeIn(duration: 350.ms).slideX(begin: 0.04, end: 0),
      ),
    );
  }
}

class _SelectedUnit extends StatelessWidget {
  const _SelectedUnit({required this.battle, required this.unit, required this.ctrl, required this.onClose});
  final Battle battle;
  final Unit unit;
  final AnimationController ctrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            final f = BattleFrame(battle, ctrl.value);
            final side = f.sideOf(unit);
            final strength = f.strengthOf(unit);
            final color = battle.colorOf(side);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    KindBadge(kindOf(unit, modern: battle.modern), color, size: 42),
                    const SizedBox(width: 8),
                    FormationPreview(unit.type, color, modern: battle.modern),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unit.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          Text('${UnitCatalog.byId(kindOf(unit, modern: battle.modern))?.nameUz ?? unitTypeName(unit.type)} · ${battle.nameOf(side)}',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: onClose, icon: const Icon(Icons.close), tooltip: 'Yopish'),
                  ],
                ),
                const SizedBox(height: 10),
                _StrengthRow(unit: unit, strength: strength, color: color),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(Icons.flag_outlined, 'Holati: ${f.stanceOf(unit).nameUz}'),
                    _Tag(Icons.category_outlined, unit.type.nameUz),
                    if (unit.type.range > 0) _Tag(Icons.gps_fixed, 'Otish masofasi ~${unit.type.range.round()} birlik'),
                    if (unit.appearAt != null) _Tag(Icons.login, '${unit.appearAt! + 1}-bosqichda yetib keladi'),
                    if (unit.leaveAt != null) _Tag(Icons.logout, '${unit.leaveAt! + 1}-bosqichda maydondan chiqadi'),
                    if (unit.hiddenUntil != null) _Tag(Icons.visibility_off_outlined, '${unit.hiddenUntil! + 1}-bosqichgacha yashirin'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(unit.type.hint, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                ),
                if (unit.defectAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${unit.defectAt! + 1}-bosqichda ${battle.nameOf(unit.side == Side.a ? Side.b : Side.a)} tomoniga o\'tgan',
                      style: const TextStyle(color: Color(0xFF8E44AD), fontWeight: FontWeight.w600),
                    ),
                  ),
                if (unit.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Text(unit.note!, style: const TextStyle(height: 1.4)),
                  ),
              ],
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, end: 0);
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF1E9D8), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: const Color(0xFF6D4C2F)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12.5)),
        ]),
      );
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.unit, required this.strength, required this.color});
  final Unit unit;
  final double strength;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fixed = unit.type.isCommand || !unit.countsAsSoldiers;
    final now = fixed ? unit.count : (unit.count * strength).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${formatCount(now)} ${unit.countUnit}'
                '${fixed ? '' : '  (boshida ${formatCount(unit.count)})'}',
                style: const TextStyle(fontSize: 13.5),
              ),
            ),
            Text('${(strength * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

// --- 1. Jang borishi -----------------------------------------------------------

class _CourseTab extends StatelessWidget {
  const _CourseTab({required this.battle, required this.phase, required this.onPhaseTap});
  final Battle battle;
  final int phase;
  final ValueChanged<int> onPhaseTap;

  @override
  Widget build(BuildContext context) {
    // Jangdagi har bir aniq tur (masalan, og'ir otliq, kamonchi, mushketyor) bir marta.
    final kinds = <String, Unit>{};
    for (final u in battle.units) {
      kinds.putIfAbsent(kindOf(u, modern: battle.modern), () => u);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'Bosqichlar',
          child: Column(
            children: [
              for (var i = 0; i < battle.phases.length; i++)
                _PhaseTile(
                  index: i,
                  phase: battle.phases[i],
                  state: i < phase ? 1 : (i == phase ? 0 : -1),
                  onTap: () => onPhaseTap(i),
                ),
            ],
          ),
        ),
        _Section(
          title: 'Qo\'shin turlari xaritada',
          child: Column(
            children: [
              for (final MapEntry(key: kind, value: u) in kinds.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      KindBadge(kind, const Color(0xFF6D4C2F), size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(UnitCatalog.byId(kind)?.nameUz ?? unitTypeName(u.type),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(UnitCatalog.byId(kind)?.nameEn ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.black45)),
                            const SizedBox(height: 2),
                            Text(unitTypeHint(u.type), style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FormationPreview(u.type, const Color(0xFF7A6A55), modern: battle.modern),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/battles/types'),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Barcha qo\'shin turlari lug\'ati'),
                ),
              ),
              const Divider(height: 20),
              const Text(
                'Bo\'linma kattaligi askarlar soniga mos: katta qo\'shin — ko\'p figura. Talafot ko\'rgan '
                'bo\'linma kichrayadi va safi tarqoqlashadi. Kengayib boruvchi strelka — joriy harakat, '
                'uzuq chiziq — bosib o\'tilgan yo\'l, xochchalar va o\'pqonlar — talafot joylari.',
                style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhaseTile extends StatelessWidget {
  const _PhaseTile({required this.index, required this.phase, required this.state, required this.onTap});
  final int index;
  final Phase phase;

  /// -1 — hali kelmagan, 0 — joriy, 1 — o'tgan.
  final int state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6D4C2F);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == 0 ? accent : (state == 1 ? const Color(0xFFBFA888) : const Color(0xFFEDE5D4)),
              ),
              child: state == 1
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : Text('${index + 1}',
                      style: TextStyle(fontSize: 12, color: state == 0 ? Colors.white : Colors.black87)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phase.title,
                      style: TextStyle(
                          fontWeight: state == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: state == 0 ? accent : Colors.black87)),
                  if (phase.notes.isNotEmpty)
                    Text(phase.notes.map((n) => n.text).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Kuchlar ------------------------------------------------------------------

class _ForcesTab extends StatelessWidget {
  const _ForcesTab({required this.battle, required this.ctrl, required this.onSelect, required this.selected});
  final Battle battle;
  final AnimationController ctrl;
  final ValueChanged<Unit?> onSelect;
  final Unit? selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final f = BattleFrame(battle, ctrl.value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              title: 'Kuchlar nisbati (xaritadagi askarlar)',
              child: ForceBar(battle: battle, a: f.soldiers(Side.a), b: f.soldiers(Side.b)),
            ),
            _Section(
              title: 'Askarlar soni bosqichma-bosqich',
              child: SizedBox(height: 190, child: _ForcesChart(battle: battle, x: f.chartX)),
            ),
            for (final side in Side.values)
              _Section(
                title: battle.nameOf(side),
                accent: battle.colorOf(side),
                child: Column(
                  children: [
                    for (final u in (battle.units.where((u) => f.sideOf(u) == side).toList()
                      ..sort((a, b) => b.count.compareTo(a.count))))
                      InkWell(
                        onTap: () => onSelect(u),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          decoration: BoxDecoration(
                            color: identical(u, selected) ? const Color(0x22FFB300) : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              KindBadge(kindOf(u, modern: battle.modern), battle.colorOf(side), size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(u.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    _StrengthRow(unit: u, strength: f.strengthOf(u), color: battle.colorOf(side)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ForcesChart extends StatelessWidget {
  const _ForcesChart({required this.battle, required this.x});
  final Battle battle;
  final double x;

  String _short(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)} mln';
    if (v >= 1e3) return '${(v / 1e3).round()} ming';
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final n = battle.phases.length;
    LineChartBarData line(Side side) {
      final c = battle.colorOf(side);
      return LineChartBarData(
        spots: [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), battle.soldiersAt(side, i.toDouble()).toDouble())],
        color: c,
        barWidth: 3,
        isCurved: true,
        preventCurveOverShooting: true,
        dotData: FlDotData(
          getDotPainter: (spot, _, _, _) =>
              FlDotCirclePainter(radius: 3.5, color: Colors.white, strokeColor: c, strokeWidth: 2),
        ),
        belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.1)),
      );
    }

    final maxY = [
      for (var i = 0; i < n; i++) ...[battle.soldiersAt(Side.a, i.toDouble()), battle.soldiersAt(Side.b, i.toDouble())]
    ].reduce((a, b) => a > b ? a : b);

    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minX: 0,
        maxX: (n - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.12,
        lineBarsData: [line(Side.a), line(Side.b)],
        extraLinesData: ExtraLinesData(verticalLines: [
          VerticalLine(x: x, color: const Color(0xFF2B2118), strokeWidth: 1.5, dashArray: [4, 4]),
        ]),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x14000000), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('bosqich oxiri', style: TextStyle(fontSize: 11, color: Colors.black45)),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 22,
              getTitlesWidget: (v, meta) => Text('${v.toInt() + 1}', style: const TextStyle(fontSize: 11)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 54,
              getTitlesWidget: (v, meta) => v == meta.max
                  ? const SizedBox.shrink()
                  : Text(_short(v), style: const TextStyle(fontSize: 10.5, color: Colors.black54)),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.white,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(formatCount(s.y), TextStyle(color: s.bar.color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Ma'lumot -------------------------------------------------------------------

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.battle});
  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final f = battle.facts;
    TableRow row(String k, Widget v) => TableRow(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: v),
        ]);
    Widget pair(String a, String b) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SideLine(color: battle.colorA, text: a),
            const SizedBox(height: 3),
            _SideLine(color: battle.colorB, text: b),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'Asosiy taktika',
          child: Text(battle.tactic,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF6D4C2F))),
        ),
        _Section(
          title: 'Jang haqida',
          child: Table(
            columnWidths: const {0: FixedColumnWidth(108)},
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              row('Sana', Text(battle.date)),
              row('Joy', Text(f.place)),
              row('Natija', Text(f.result, style: const TextStyle(fontWeight: FontWeight.w600))),
              row('Qo\'mondonlar', pair(f.commandersA, f.commandersB)),
              row('Kuchlar', pair(f.forcesA, f.forcesB)),
              row('Yo\'qotishlar', pair(f.lossesA, f.lossesB)),
            ],
          ),
        ),
        _Section(title: 'Qisqacha', child: Text(battle.summary, style: const TextStyle(height: 1.45))),
        _Section(title: 'Saboq', child: Text(battle.lesson, style: const TextStyle(height: 1.45))),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: const Icon(Icons.public),
            title: const Text('Haqiqiy xaritadagi joyi'),
            subtitle: Text('${battle.lat.toStringAsFixed(2)}°, ${battle.lng.toStringAsFixed(2)}°'),
            children: [SizedBox(height: 260, child: _LocatorMap(battle: battle))],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(battle.wiki), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Wikipedia\'da batafsil (ingliz tilida)'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            'Xaritadagi joylashuvlar sxematik. Askarlar soni va yo\'qotishlar — tarixiy manbalardagi '
            'taxminiy baholar, ular manbadan manbaga farq qiladi. Qo\'shin turlari ikonlari: game-icons.net '
            '(Lorc, Delapouite, Skoll va boshqalar), CC BY 3.0.',
            style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _SideLine extends StatelessWidget {
  const _SideLine({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      );
}

class _LocatorMap extends StatelessWidget {
  const _LocatorMap({required this.battle});
  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(battle.lat, battle.lng);
    return fm.FlutterMap(
      options: fm.MapOptions(initialCenter: point, initialZoom: battle.zoom),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'uz.boqiyqahramonlar.app',
        ),
        fm.MarkerLayer(markers: [
          fm.Marker(
            point: point,
            width: 44,
            height: 44,
            alignment: Alignment.topCenter,
            child: const Icon(Icons.location_on, size: 44, color: Color(0xFFB3261E)),
          ),
        ]),
        fm.RichAttributionWidget(
          attributions: [
            fm.TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.accent});
  final String title;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (accent != null) ...[
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(title.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(letterSpacing: 1.2, color: Colors.black54, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
