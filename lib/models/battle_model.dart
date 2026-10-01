import 'dart:convert';

import '../battle/data/battle_json.dart';
import '../battle/data/validate.dart';
import '../battle/models.dart';

/// Admin paneldan qo'shilgan jang yozuvi.
///
/// Backend javobi (`GET battles`, `GET battles/{id}`):
/// ```json
/// {
///   "id": 7,
///   "battleJson": "{ \"schemaVersion\": 1, \"id\": \"ankara\", ... }",
///   "view_count": 120,
///   "createAt": "...",
///   "updatedAt": "..."
/// }
/// ```
/// `battleJson` — admin panelga kiritilgan jang JSON'i (matn yoki obyekt
/// ko'rinishida). Agar o'rovchi yozuv bo'lmasa, elementning o'zi jang JSON'i
/// deb qabul qilinadi (ilova ichidagi namunalar shu ko'rinishda).
class BattleModel {
  final num? id;
  final Battle battle;
  final num? viewCount;
  final String? createAt;
  final String? updatedAt;

  BattleModel({
    this.id,
    required this.battle,
    this.viewCount,
    this.createAt,
    this.updatedAt,
  });

  /// Sahifa manzili uchun kalit: backend yozuvi bo'lsa uning raqamli id'si,
  /// aks holda jang JSON'idagi `id` (masalan, "ankara").
  String get key => id?.toString() ?? battle.id;

  /// JSON noto'g'ri yoki jang ma'lumotlari ziddiyatli bo'lsa
  /// [FormatException] tashlaydi — xabarda aniq sabab yoziladi.
  factory BattleModel.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    final raw = map['battleJson'] ?? map['data'];
    final hasWrapper = raw != null;
    final Map<String, dynamic> battleMap = switch (raw) {
      String s => Map<String, dynamic>.from(jsonDecode(s) as Map),
      Map m => Map<String, dynamic>.from(m),
      _ => map,
    };

    final Battle battle;
    try {
      battle = battleFromJson(battleMap);
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException("Jang JSON'i sxemaga mos emas: $e");
    }
    final errors = validateBattle(battle);
    if (errors.isNotEmpty) throw FormatException(errors.join('\n'));

    return BattleModel(
      id: hasWrapper ? map['id'] as num? : null,
      battle: battle,
      viewCount: hasWrapper ? map['view_count'] as num? : null,
      createAt: hasWrapper ? map['createAt'] as String? : null,
      updatedAt: hasWrapper ? map['updatedAt'] as String? : null,
    );
  }
}
