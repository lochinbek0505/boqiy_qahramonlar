import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/battle_model.dart';
import '../service/api_service.dart';
import 'models/battle_state.dart';

final battleProvider = StateNotifierProvider<BattleNotifier, BattleState>((ref) {
  return BattleNotifier();
});

/// Backend hali `battles` endpointini bermasa ko'rsatiladigan namunalar
/// (assets/battles/*.json — war_startegy loyihasidagi janglar).
const _sampleBattles = [
  'ankara',
  'indus',
  'kalka',
  'malazgirt',
  'austerlitz',
  'tannenberg',
  'france1940',
  'stalingrad',
];

class BattleNotifier extends StateNotifier<BattleState> {
  BattleNotifier() : super(BattleState()) {
    fetchBattles();
  }

  final ApiService _apiService = ApiService();

  /// Hozir ketayotgan yuklash — sahifa to'g'ridan-to'g'ri havola orqali
  /// ochilganda [findBattle] shu tugashini kutadi.
  Future<void>? _pending;

  Future<void> fetchBattles() => _pending = _fetchBattles();

  Future<void> _fetchBattles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final battles = await _apiService.getBattles();
    if (battles != null) {
      state = state.copyWith(isLoading: false, battles: battles, isSample: false);
      return;
    }
    try {
      final samples = <BattleModel>[];
      for (final name in _sampleBattles) {
        final raw = await rootBundle.loadString('assets/battles/$name.json');
        samples.add(BattleModel.fromJson({'battleJson': raw}));
      }
      state = state.copyWith(isLoading: false, battles: samples, isSample: true);
    } catch (e) {
      debugPrint('Namuna janglar yuklanmadi: $e');
      state = state.copyWith(
        isLoading: false,
        error: "Janglarni yuklashda xatolik yuz berdi!",
      );
    }
  }

  /// Ro'yxatdan yoki (raqamli kalit bo'lsa) backenddan bitta jangni topadi.
  Future<BattleModel?> findBattle(String key) async {
    if (state.isLoading) {
      await _pending;
    } else if (state.battles.isEmpty) {
      await fetchBattles();
    }
    for (final b in state.battles) {
      if (b.key == key) return b;
    }
    final id = int.tryParse(key);
    if (id == null) return null;
    return _apiService.getBattleById(id);
  }

  Future<void> increaseBattleView(BattleModel battle) async {
    final id = battle.id;
    if (id == null) return;
    await _apiService.increaseBattleView(id.toInt());
  }
}
