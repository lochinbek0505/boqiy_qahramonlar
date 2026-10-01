import 'dart:convert';

import 'package:flutter/painting.dart';

import '../models.dart';

/// JSON sxema versiyasi. Maydonlar o'zgarsa oshiriladi — backend eski yozuvlarni
/// shu raqam bo'yicha migratsiya qiladi.
const battleSchemaVersion = 1;

// Jangni backend/admin panel bilan almashish uchun JSON ko'rinishi.
// Sxemaning to'liq tavsifi: docs/JANG_MALUMOTLARI.md va docs/battle.schema.json

Map<String, dynamic> battleToJson(Battle b) => {
      'schemaVersion': battleSchemaVersion,
      'id': b.id,
      'commander': b.commander,
      'name': b.name,
      'date': b.date,
      'tactic': b.tactic,
      'summary': b.summary,
      'lesson': b.lesson,
      if (b.aftermath.isNotEmpty) 'aftermath': b.aftermath,
      'sides': {
        'a': {'name': b.sideA, 'color': _hex(b.colorA)},
        'b': {'name': b.sideB, 'color': _hex(b.colorB)},
      },
      'winner': b.winner.name,
      'biome': b.biome.name,
      'modern': b.modern,
      'location': {'lat': b.lat, 'lng': b.lng, 'zoom': b.zoom, 'kmAcross': b.kmAcross},
      'wiki': b.wiki,
      'facts': {
        'place': b.facts.place,
        'result': b.facts.result,
        'commandersA': b.facts.commandersA,
        'commandersB': b.facts.commandersB,
        'forcesA': b.facts.forcesA,
        'forcesB': b.facts.forcesB,
        'lossesA': b.facts.lossesA,
        'lossesB': b.facts.lossesB,
      },
      'terrain': [
        for (final t in b.terrain)
          {
            'kind': t.kind.name,
            'points': [for (final o in t.points) _pt(o)],
            if (t.label != null) 'label': t.label,
            if (t.size != 6) 'size': t.size,
          },
      ],
      'phases': [
        for (final ph in b.phases)
          {
            'title': ph.title,
            'text': ph.text,
            'notes': [
              for (final n in ph.notes) {'pos': _pt(n.pos), 'text': n.text, 'kind': n.kind.name},
            ],
          },
      ],
      'units': [
        for (final u in b.units)
          {
            'label': u.label,
            'side': u.side.name,
            'type': u.type.name,
            'count': u.count,
            if (u.countUnit != 'askar') 'countUnit': u.countUnit,
            if (u.kind != null) 'kind': u.kind,
            if (u.note != null) 'note': u.note,
            'positions': [for (final o in u.positions) _pt(o)],
            if (u.strength != null) 'strength': u.strength,
            if (u.defectAt != null) 'defectAt': u.defectAt,
            if (u.appearAt != null) 'appearAt': u.appearAt,
            if (u.leaveAt != null) 'leaveAt': u.leaveAt,
            if (u.hiddenUntil != null) 'hiddenUntil': u.hiddenUntil,
            if (u.via.isNotEmpty)
              'via': {for (final e in u.via.entries) '${e.key}': [for (final o in e.value) _pt(o)]},
            if (u.stances.isNotEmpty) 'stances': {for (final e in u.stances.entries) '${e.key}': e.value.name},
          },
      ],
    };

/// JSON'dan jang. Noma'lum qiymatlar (masalan, mavjud bo'lmagan qo'shin turi) uchun
/// [FormatException] tashlanadi — xabarda qaysi maydon ekanligi yoziladi.
/// Mazmuniy tekshiruv (bosqichlar soni, koordinatalar ...) uchun keyin [validateBattle] chaqiring.
Battle battleFromJson(Map<String, dynamic> j) {
  final v = j['schemaVersion'] as int? ?? 1;
  if (v > battleSchemaVersion) {
    throw FormatException('schemaVersion $v — ilova faqat $battleSchemaVersion gacha qo\'llaydi');
  }
  final sides = j['sides'] as Map<String, dynamic>;
  final loc = j['location'] as Map<String, dynamic>;
  final facts = j['facts'] as Map<String, dynamic>;
  return Battle(
    id: j['id'] as String,
    commander: j['commander'] as String? ?? '',
    name: j['name'] as String,
    date: j['date'] as String,
    tactic: j['tactic'] as String? ?? '',
    summary: j['summary'] as String? ?? '',
    lesson: j['lesson'] as String? ?? '',
    aftermath: j['aftermath'] as String? ?? '',
    sideA: (sides['a'] as Map)['name'] as String,
    sideB: (sides['b'] as Map)['name'] as String,
    colorA: _color((sides['a'] as Map)['color'] as String),
    colorB: _color((sides['b'] as Map)['color'] as String),
    winner: _enum(Side.values, j['winner'] ?? 'a', 'winner'),
    biome: _enum(Biome.values, j['biome'], 'biome'),
    modern: j['modern'] as bool? ?? false,
    lat: (loc['lat'] as num).toDouble(),
    lng: (loc['lng'] as num).toDouble(),
    zoom: (loc['zoom'] as num? ?? 8).toDouble(),
    kmAcross: (loc['kmAcross'] as num).toDouble(),
    wiki: j['wiki'] as String? ?? '',
    facts: BattleFacts(
      place: facts['place'] as String? ?? '',
      result: facts['result'] as String? ?? '',
      commandersA: facts['commandersA'] as String? ?? '',
      commandersB: facts['commandersB'] as String? ?? '',
      forcesA: facts['forcesA'] as String? ?? '',
      forcesB: facts['forcesB'] as String? ?? '',
      lossesA: facts['lossesA'] as String? ?? '',
      lossesB: facts['lossesB'] as String? ?? '',
    ),
    terrain: [
      for (final t in (j['terrain'] as List? ?? const []).cast<Map<String, dynamic>>())
        Terrain(
          _enum(TerrainKind.values, t['kind'], 'terrain.kind'),
          [for (final p in t['points'] as List) _off(p)],
          label: t['label'] as String?,
          size: (t['size'] as num? ?? 6).toDouble(),
        ),
    ],
    phases: [
      for (final ph in (j['phases'] as List).cast<Map<String, dynamic>>())
        Phase(
          ph['title'] as String,
          ph['text'] as String? ?? '',
          notes: [
            for (final n in (ph['notes'] as List? ?? const []).cast<Map<String, dynamic>>())
              MapNote(_off(n['pos']), n['text'] as String, _enum(NoteKind.values, n['kind'] ?? 'info', 'note.kind')),
          ],
        ),
    ],
    units: [
      for (final u in (j['units'] as List).cast<Map<String, dynamic>>())
        Unit(
          u['label'] as String,
          _enum(Side.values, u['side'], 'unit.side'),
          _enum(UnitType.values, u['type'], 'unit.type'),
          u['count'] as int,
          [for (final p in u['positions'] as List) _off(p)],
          countUnit: u['countUnit'] as String? ?? 'askar',
          kind: u['kind'] as String?,
          note: u['note'] as String?,
          strength: (u['strength'] as List?)?.map((e) => (e as num).toDouble()).toList(),
          defectAt: u['defectAt'] as int?,
          appearAt: u['appearAt'] as int?,
          leaveAt: u['leaveAt'] as int?,
          hiddenUntil: u['hiddenUntil'] as int?,
          via: {
            for (final e in (u['via'] as Map<String, dynamic>? ?? const {}).entries)
              int.parse(e.key): [for (final p in e.value as List) _off(p)],
          },
          stances: {
            for (final e in (u['stances'] as Map<String, dynamic>? ?? const {}).entries)
              int.parse(e.key): _enum(Stance.values, e.value, 'unit.stances'),
          },
        ),
    ],
  );
}

String battleToJsonString(Battle b) => const JsonEncoder.withIndent('  ').convert(battleToJson(b));
Battle battleFromJsonString(String s) => battleFromJson(jsonDecode(s) as Map<String, dynamic>);

List<num> _pt(Offset o) => [_num(o.dx), _num(o.dy)];
num _num(double v) => v == v.roundToDouble() ? v.round() : v;
Offset _off(Object? p) {
  final l = p as List;
  return Offset((l[0] as num).toDouble(), (l[1] as num).toDouble());
}

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
Color _color(String s) {
  final h = s.replaceFirst('#', '');
  if (h.length != 6) throw FormatException('Rang "#RRGGBB" ko\'rinishida bo\'lishi kerak: $s');
  return Color(0xFF000000 | int.parse(h, radix: 16));
}

T _enum<T extends Enum>(List<T> values, Object? name, String field) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  throw FormatException('$field: "$name" noma\'lum. Mumkin qiymatlar: ${values.map((e) => e.name).join(', ')}');
}
