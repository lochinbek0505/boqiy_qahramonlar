import 'package:flutter/material.dart';

import 'unit_types.dart';

export 'unit_types.dart';

/// Jangdagi ikki tomon: A — birinchi (odatda asosiy qahramon), B — raqib.
enum Side { a, b }

String unitTypeName(UnitType t) => t.nameUz;
String unitTypeHint(UnitType t) => t.hint;

/// Barcha koordinatalar 0..100 oralig'ida (x — chapdan o'ngga, y — yuqoridan pastga).
Offset p(double x, double y) => Offset(x, y);

class Unit {
  const Unit(
    this.label,
    this.side,
    this.type,
    this.count,
    this.positions, {
    this.strength,
    this.defectAt,
    this.countUnit = 'askar',
    this.note,
    this.kind,
    this.appearAt,
    this.leaveAt,
    this.hiddenUntil,
    this.via = const {},
    this.stances = const {},
  });

  final String label;
  final Side side;
  final UnitType type;

  /// Jang boshidagi taxminiy son (askar, fil, samolyot ...).
  final int count;

  /// [count] nimani sanaydi. Faqat 'askar' umumiy kuchlarga qo'shiladi.
  final String countUnit;

  /// Qisqa izoh (bo'linma bosilganda ko'rsatiladi).
  final String? note;

  /// Katalogdagi aniq turi (ikon uchun), masalan 'heavy_cavalry', 'musketeer'.
  /// Berilmasa [type] va davrga qarab tanlanadi — [kindOf].
  final String? kind;

  /// positions[i] — i-bosqich oxiridagi joylashuv. Uzunligi bosqichlar soniga teng.
  final List<Offset> positions;

  /// strength[i] — i-bosqich oxiridagi kuch (1 — to'liq, 0 — yo'q qilingan).
  final List<double>? strength;

  /// Shu bosqichdan boshlab bo'linma raqib tomonga o'tadi.
  final int? defectAt;

  /// Qo'shimcha kuch: shu bosqichda xaritada paydo bo'ladi (undan oldin ko'rinmaydi).
  final int? appearAt;

  /// Shu bosqichda xaritadan chiqib ketadi (evakuatsiya, yo'q qilinish) — keyin ko'rinmaydi.
  final int? leaveAt;

  /// Pistirma: shu bosqichgacha yashirin (xira, uzuq chiziqli) ko'rsatiladi.
  final int? hiddenUntil;

  /// Oraliq nuqtalar: `{2: [p(40, 90), p(30, 85)]}` — 2-bosqichda to'g'ri emas,
  /// shu nuqtalar orqali harakatlanadi (masalan, tog' ortidan aylanib o'tish).
  final Map<int, List<Offset>> via;

  /// Holatni qo'lda belgilash: `{4: Stance.surrender}`. Berilmasa avtomatik aniqlanadi.
  final Map<int, Stance> stances;

  /// i-bosqichda bo'linma umuman ko'rinadimi (paydo bo'lish/chiqib ketish hisobga olingan).
  bool presentAt(int i) => (appearAt == null || i >= appearAt!) && (leaveAt == null || i < leaveAt!);

  bool get countsAsSoldiers => countUnit == 'askar';

  double strengthAt(int i) => strength == null ? 1 : strength![i];

  Side sideAt(int phase) {
    if (defectAt != null && phase >= defectAt!) {
      return side == Side.a ? Side.b : Side.a;
    }
    return side;
  }
}

/// Bo'linmaning katalogdagi turi (SVG ikon).
String kindOf(Unit u, {required bool modern}) => u.kind ?? u.type.iconFor(modern: modern);

enum TerrainKind { river, lake, hill, forest, mountains, city, rail, fortLine, border, label }

class Terrain {
  const Terrain(this.kind, this.points, {this.label, this.size = 6});

  final TerrainKind kind;
  final List<Offset> points;
  final String? label;

  /// Tepalik/o'rmon/ko'l radiusi yoki daryo qalinligi.
  final double size;
}

enum NoteKind { info, attack, betrayal, trap, water, air, capture, weather }

/// Bosqich davomida xaritada paydo bo'ladigan izoh.
class MapNote {
  const MapNote(this.pos, this.text, [this.kind = NoteKind.info]);
  final Offset pos;
  final String text;
  final NoteKind kind;
}

class Phase {
  const Phase(this.title, this.text, {this.notes = const []});
  final String title;
  final String text;
  final List<MapNote> notes;
}

/// Xarita landshafti: rang palitrasi va tafsilotlar.
enum Biome {
  dry, // yozgi quruq dasht (Anqara)
  arid, // cho'l, daryo bo'yi yashil (Sind)
  steppe, // o'tloqli dasht (Kalka)
  frost, // qishki ayoz, yupqa qor (Austerlits)
  summer, // yashil ekinzorlar (Sharqiy Prussiya)
  spring, // bahorgi dalalar (Fransiya)
  snow, // qalin qor (Stalingrad)
}

class Battle {
  const Battle({
    required this.id,
    required this.commander,
    required this.name,
    required this.date,
    required this.tactic,
    required this.summary,
    required this.lesson,
    required this.sideA,
    required this.sideB,
    required this.colorA,
    required this.colorB,
    required this.biome,
    required this.terrain,
    required this.units,
    required this.phases,
    required this.facts,
    required this.lat,
    required this.lng,
    required this.zoom,
    required this.kmAcross,
    required this.wiki,
    this.modern = false,
    this.winner = Side.a,
    this.aftermath = '',
  });

  final String id;
  final String commander;
  final String name;
  final String date;
  final String tactic;
  final String summary;
  final String lesson;
  final String sideA;
  final String sideB;
  final Color colorA;
  final Color colorB;
  final Biome biome;
  final List<Terrain> terrain;
  final List<Unit> units;
  final List<Phase> phases;

  /// Jadvaldagi ma'lumotlar: joy, natija, qo'mondonlar, kuchlar, yo'qotishlar.
  final BattleFacts facts;

  /// Jang joyining haqiqiy koordinatalari (lokator xaritasi uchun).
  final double lat, lng, zoom;

  /// Xarita kengligi taxminan necha km (masshtab chizig'i uchun).
  final double kmAcross;

  /// Batafsil o'qish uchun havola.
  final String wiki;

  /// XX asr jangi: portlashlar, tutun, zamonaviy shaharlar.
  final bool modern;

  /// G'olib tomon — jang oxiridagi yakun animatsiyasi uchun.
  final Side winner;

  /// Jangdan keyin nima bo'ldi (tarixiy oqibatlari) — yakun oynasida ko'rsatiladi.
  final String aftermath;

  Color colorOf(Side s) => s == Side.a ? colorA : colorB;
  String nameOf(Side s) => s == Side.a ? sideA : sideB;

  /// i-bosqich oxirida tomonning xaritadagi askarlari soni.
  int soldiersAt(Side side, double progressPhase) {
    final i = progressPhase.floor().clamp(0, phases.length - 1);
    var total = 0.0;
    for (final u in units) {
      if (!u.countsAsSoldiers || u.sideAt(i) != side || !u.presentAt(i)) continue;
      total += u.count * u.strengthAt(i);
    }
    return total.round();
  }

  int get maxCount => units.where((u) => u.countsAsSoldiers).fold(0, (m, u) => u.count > m ? u.count : m);
}

class BattleFacts {
  const BattleFacts({
    required this.place,
    required this.result,
    required this.commandersA,
    required this.commandersB,
    required this.forcesA,
    required this.forcesB,
    required this.lossesA,
    required this.lossesB,
  });

  final String place;
  final String result;
  final String commandersA, commandersB;
  final String forcesA, forcesB;
  final String lossesA, lossesB;
}

class Era {
  const Era(this.title, this.subtitle, this.icon, this.battles);
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Battle> battles;
}

/// 140000 -> "140 000"
String formatCount(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}
