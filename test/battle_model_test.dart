import 'dart:convert';
import 'dart:io';

import 'package:boqiy_qahramonlar/battle/data/unit_catalog.dart';
import 'package:boqiy_qahramonlar/models/battle_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => UnitCatalog.load());

  final samples = Directory('assets/battles').listSync().whereType<File>().where((f) => f.path.endsWith('.json'));

  for (final f in samples) {
    test('namuna ${f.uri.pathSegments.last} — xatosiz o\'qiladi', () {
      final m = BattleModel.fromJson({'battleJson': f.readAsStringSync()});
      expect(m.id, isNull);
      expect(m.key, m.battle.id);
    });
  }

  test('backend yozuvi: battleJson matn ko\'rinishida', () {
    final raw = File('assets/battles/ankara.json').readAsStringSync();
    final m = BattleModel.fromJson({'id': 7, 'battleJson': raw, 'view_count': 3});
    expect(m.key, '7');
    expect(m.viewCount, 3);
    expect(m.battle.name, isNotEmpty);
  });

  test('backend yozuvi: battleJson obyekt ko\'rinishida', () {
    final obj = jsonDecode(File('assets/battles/kalka.json').readAsStringSync());
    final m = BattleModel.fromJson({'id': 8, 'battleJson': obj});
    expect(m.key, '8');
  });

  test('noto\'g\'ri jang FormatException beradi', () {
    final obj = jsonDecode(File('assets/battles/kalka.json').readAsStringSync()) as Map<String, dynamic>;
    (obj['units'] as List).first['type'] = 'yoq_tur';
    expect(() => BattleModel.fromJson({'id': 9, 'battleJson': obj}), throwsFormatException);
    obj.remove('phases');
    expect(() => BattleModel.fromJson({'id': 9, 'battleJson': obj}), throwsFormatException);
  });
}
