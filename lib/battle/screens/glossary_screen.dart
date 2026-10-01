import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/unit_catalog.dart';

/// Qo'shin turlari, texnika, taktik belgilar va relyef — SVG ikonlari bilan lug'at.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _era = 'historical';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = UnitCatalog.all.where((k) {
      if (q.isNotEmpty) {
        return k.nameUz.toLowerCase().contains(q) || k.nameEn.toLowerCase().contains(q) || k.id.contains(q);
      }
      return k.era == _era;
    }).toList();
    final categories = <String, List<UnitKind>>{};
    for (final k in items) {
      categories.putIfAbsent(k.category, () => []).add(k);
    }
    final width = MediaQuery.sizeOf(context).width;
    final tileWidth = width < 520 ? (width - 44) / 2 : 230.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/battles'),
        ),
        title: const Text('Qo\'shin turlari lug\'ati'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<String>(
                segments: [
                  for (final e in eraNames.entries) ButtonSegment(value: e.key, label: Text(e.value)),
                ],
                selected: {_era},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() {
                  _era = s.first;
                  _query = '';
                }),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Qidirish: kamonchi, tank, drone…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ],
          ),
          for (final entry in categories.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
              child: Text(categoryNames[entry.key] ?? entry.key, style: Theme.of(context).textTheme.titleLarge),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < entry.value.length; i++)
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: tileWidth).copyWith(minHeight: 86),
                    child: _KindTile(entry.value[i]),
                  )
                      .animate(delay: (20 * i).ms)
                      .fadeIn(duration: 250.ms)
                      .scaleXY(begin: 0.96, end: 1),
              ],
            ),
          ],
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Hech narsa topilmadi')),
            ),
          const SizedBox(height: 24),
          const Text(
            'Ikonlar: game-icons.net (Lorc, Delapouite, Skoll, Sbed, Cathelineau va boshqalar), '
            'litsenziya CC BY 3.0. Ilovada rangga bo\'yash uchun fonlari olib tashlangan.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse('https://game-icons.net'), mode: LaunchMode.externalApplication),
            child: const Text('game-icons.net saytini ochish'),
          ),
        ],
      ),
    );
  }
}

class _KindTile extends StatelessWidget {
  const _KindTile(this.kind);
  final UnitKind kind;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E9D8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: KindIcon(kind.id, size: 34, color: const Color(0xFF3A2A1C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kind.nameUz, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(kind.nameEn, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
