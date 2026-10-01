import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/unit_catalog.dart';
import '../map/frame.dart';
import '../models.dart';

// Xaritadan TASHQARIDA turadigan boshqaruv elementlari: sarlavha, kuchlar, voqealar.

/// Voqea turiga mos taktik ikon (katalogdan) yoki Material ikon.
String? noteKindIcon(NoteKind k) => switch (k) {
      NoteKind.attack => 'main_effort',
      NoteKind.betrayal => 'flanking',
      NoteKind.trap => 'encirclement',
      NoteKind.water => 'river',
      NoteKind.air => 'bomber',
      NoteKind.capture => 'rally_point',
      NoteKind.info || NoteKind.weather => null,
    };

IconData noteMaterialIcon(NoteKind k) =>
    k == NoteKind.weather ? Icons.cloud_outlined : Icons.info_outline;

Color noteColor(NoteKind k) => switch (k) {
      NoteKind.info => const Color(0xFF3D5A80),
      NoteKind.attack => const Color(0xFFC0392B),
      NoteKind.betrayal => const Color(0xFF8E44AD),
      NoteKind.trap => const Color(0xFFD35400),
      NoteKind.water => const Color(0xFF1F78B4),
      NoteKind.air => const Color(0xFF34495E),
      NoteKind.capture => const Color(0xFF27613E),
      NoteKind.weather => const Color(0xFF607D8B),
    };

/// Xaritadagi voqea raqami (1, 2 ...) — pastdagi matn bilan bog'lanadi.
class NoteNumber extends StatelessWidget {
  const NoteNumber({super.key, required this.index, required this.kind, this.size = 22, this.pulse = false});
  final int index;
  final NoteKind kind;
  final double size;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final color = noteColor(kind);
    final dot = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 5, offset: Offset(0, 1))],
      ),
      child: Text('${index + 1}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.5, height: 1)),
    );
    if (!pulse) return dot;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(begin: 1, end: 2.2, duration: 1500.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1500.ms),
          dot,
        ],
      ),
    );
  }
}

/// Xarita tepasidagi panel: bosqich nomi va tomonlarning jonli askarlar soni.
class BattleHeader extends StatelessWidget {
  const BattleHeader({super.key, required this.battle, required this.progress, this.dark = false, this.trailing});
  final Battle battle;
  final ValueListenable<double> progress;
  final bool dark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? const Color(0xFFF3E6CC) : const Color(0xFF2B2118);
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        final f = BattleFrame(battle, value);
        final phase = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF6D4C2F) : const Color(0xFF2B2118),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${f.phase + 1}/${battle.phases.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(battle.phases[f.phase].title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: mapSerif, fontSize: 18, fontWeight: FontWeight.w700, color: fg))
                  // Yangi bosqich boshlanganini aniq ko'rsatish: sarlavha kirib keladi va yarqiraydi.
                  .animate(key: ValueKey('title-${f.phase}'))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.15, end: 0, duration: 450.ms, curve: Curves.easeOutCubic)
                  .then()
                  .shimmer(duration: 900.ms, color: const Color(0xFFE0B25B)),
            ),
          ],
        );
        final forces = Wrap(
          spacing: 14,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final side in Side.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 11,
                      height: 11,
                      decoration:
                          BoxDecoration(color: battle.colorOf(side), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 6),
                  Text(battle.nameOf(side), style: TextStyle(fontSize: 13.5, color: fg.withValues(alpha: 0.85))),
                  const SizedBox(width: 6),
                  Text(formatCount(f.soldiers(side)),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: dark ? Color.lerp(battle.colorOf(side), Colors.white, 0.45) : battle.colorOf(side))),
                ],
              ),
          ],
        );
        return LayoutBuilder(builder: (context, c) {
          final narrow = c.maxWidth < 720;
          final content = narrow
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [phase, const SizedBox(height: 6), forces])
              : Row(children: [Expanded(child: phase), const SizedBox(width: 16), forces]);
          return Row(
            children: [
              Expanded(child: content),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );
        });
      },
    );
  }
}

/// Joriy bosqich voqealari — xarita ostida, raqamlari xaritadagi belgilarga mos.
class EventsStrip extends StatelessWidget {
  const EventsStrip({super.key, required this.battle, required this.phase, this.dark = false});
  final Battle battle;
  final int phase;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final notes = battle.phases[phase].notes;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (var i = 0; i < notes.length; i++)
          Container(
            key: ValueKey('$phase-$i'),
            padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF3A2E24) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: noteColor(notes[i].kind).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NoteNumber(index: i, kind: notes[i].kind, size: 22),
                const SizedBox(width: 8),
                if (noteKindIcon(notes[i].kind) case final id?)
                  KindIcon(id, size: 18, color: noteColor(notes[i].kind))
                else
                  Icon(noteMaterialIcon(notes[i].kind), size: 18, color: noteColor(notes[i].kind)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(notes[i].text,
                      style: TextStyle(
                          fontFamily: mapSerif,
                          fontSize: 14,
                          color: dark ? const Color(0xFFF3E6CC) : const Color(0xFF2B2118))),
                ),
              ],
            ),
          ).animate(delay: (250 + i * 300).ms).fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }
}


/// Bosqichlar tasmasi: har bir bosqich — alohida bo'lak, joriysi ajratilgan va to'lib boradi.
/// Bo'lakni bosib, o'sha bosqichga o'tish mumkin.
class PhaseTimeline extends StatelessWidget {
  const PhaseTimeline({super.key, required this.battle, required this.progress, required this.onPhaseTap, this.dark = false});
  final Battle battle;
  final ValueListenable<double> progress;
  final ValueChanged<int> onPhaseTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB07A3A);
    final track = dark ? const Color(0xFF3A2E24) : const Color(0xFFE8DFCC);
    final fg = dark ? const Color(0xFFF3E6CC) : const Color(0xFF2B2118);
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        final current = BattleFrame(battle, value).phase;
        return Row(
          children: [
            for (var i = 0; i < battle.phases.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onPhaseTap(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: i == current ? 7 : 5,
                            child: Stack(fit: StackFit.expand, children: [
                              ColoredBox(color: track),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (value - i).clamp(0.0, 1.0),
                                child: ColoredBox(color: i == current ? accent : accent.withValues(alpha: 0.6)),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${i + 1}. ${battle.phases[i].title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                            color: i == current ? (dark ? const Color(0xFFE0B25B) : const Color(0xFF6D4C2F)) : fg.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
