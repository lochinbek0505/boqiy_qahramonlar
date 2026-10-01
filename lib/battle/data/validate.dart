import 'dart:ui' show Offset;

import '../models.dart';
import 'unit_catalog.dart';

/// Jang ma'lumotlaridagi xatolarni o'zbekcha, aniq joyi bilan qaytaradi.
/// Bo'sh ro'yxat — hammasi to'g'ri.
///
/// Testlar (`flutter test`) har bir jangni shu funksiya bilan tekshiradi, shuning uchun
/// yangi jang qo'shganingizda xato bo'lsa, qaysi bo'linmada nima noto'g'ri ekani darhol ko'rinadi.
List<String> validateBattle(Battle b, {bool checkIcons = true}) {
  final errors = <String>[];
  final n = b.phases.length;
  void err(String where, String msg) => errors.add('[${b.id}] $where: $msg');
  bool inMap(Offset o) => o.dx >= 0 && o.dx <= 100 && o.dy >= 0 && o.dy <= 100;

  if (b.id.isEmpty || b.id.contains(RegExp(r'[^a-z0-9_]'))) {
    err('id', '"${b.id}" — faqat kichik lotin harflari, raqam va _ bo\'lishi kerak (manzilda ishlatiladi)');
  }
  if (n < 2) err('phases', 'kamida 2 ta bosqich kerak (hozir $n ta)');
  if (b.units.isEmpty) err('units', 'bo\'linmalar yo\'q');
  if (!b.units.any((u) => u.side == Side.a) || !b.units.any((u) => u.side == Side.b)) {
    err('units', 'ikkala tomonda (Side.a va Side.b) kamida bitta bo\'linma bo\'lishi kerak');
  }
  if (b.lat.abs() > 90 || b.lng.abs() > 180) err('lat/lng', 'koordinatalar noto\'g\'ri: ${b.lat}, ${b.lng}');
  if (b.kmAcross <= 0) err('kmAcross', 'musbat son bo\'lishi kerak');

  for (var i = 0; i < n; i++) {
    for (final note in b.phases[i].notes) {
      if (!inMap(note.pos)) err('${i + 1}-bosqich izohi "${note.text}"', 'joylashuv 0..100 dan tashqarida: ${note.pos}');
    }
  }

  final labels = <String>{};
  for (final u in b.units) {
    final w = 'bo\'linma "${u.label}"';
    if (!labels.add('${u.side}/${u.label}')) err(w, 'bir tomonda ikki xil bo\'linmaning nomi bir xil');
    if (u.positions.length != n) {
      err(w, 'positions ro\'yxatida ${u.positions.length} ta nuqta bor, bosqichlar esa $n ta — soni teng bo\'lishi kerak');
    }
    for (var i = 0; i < u.positions.length; i++) {
      if (!inMap(u.positions[i])) err(w, '${i + 1}-nuqta 0..100 dan tashqarida: ${u.positions[i]}');
    }
    if (u.strength != null) {
      if (u.strength!.length != n) {
        err(w, 'strength ro\'yxatida ${u.strength!.length} ta qiymat bor, $n ta bo\'lishi kerak');
      }
      for (final v in u.strength!) {
        if (v < 0 || v > 1) err(w, 'strength qiymati 0..1 oralig\'ida bo\'lishi kerak (topildi: $v)');
      }
    }
    if (u.count <= 0) err(w, 'count musbat son bo\'lishi kerak');
    for (final (name, v) in [('defectAt', u.defectAt), ('appearAt', u.appearAt), ('leaveAt', u.leaveAt),
      ('hiddenUntil', u.hiddenUntil)]) {
      if (v != null && (v < 0 || v >= n)) err(w, '$name = $v, lekin bosqich raqami 0..${n - 1} bo\'lishi kerak');
    }
    if (u.appearAt != null && u.leaveAt != null && u.leaveAt! <= u.appearAt!) {
      err(w, 'leaveAt appearAt dan keyin bo\'lishi kerak');
    }
    for (final e in u.via.entries) {
      if (e.key < 1 || e.key >= n) err(w, 'via kaliti ${e.key} — 1..${n - 1} bo\'lishi kerak (0-bosqichda harakat yo\'q)');
      for (final o in e.value) {
        if (!inMap(o)) err(w, 'via nuqtasi 0..100 dan tashqarida: $o');
      }
    }
    for (final k in u.stances.keys) {
      if (k < 0 || k >= n) err(w, 'stances kaliti $k — 0..${n - 1} bo\'lishi kerak');
    }
    if (checkIcons && UnitCatalog.isLoaded && UnitCatalog.byId(kindOf(u, modern: b.modern)) == null) {
      err(w, 'ikon "${kindOf(u, modern: b.modern)}" katalogda yo\'q (assets/units/catalog.json)');
    }
  }
  return errors;
}
