import '../../models/battle_model.dart';

class BattleState {
  final bool isLoading;
  final String? error;
  final List<BattleModel> battles;

  /// true — backend javob bermadi, ilova ichidagi namuna janglar ko'rsatilmoqda.
  final bool isSample;

  BattleState({
    this.isLoading = false,
    this.error,
    this.battles = const [],
    this.isSample = false,
  });

  BattleState copyWith({
    bool? isLoading,
    String? error,
    List<BattleModel>? battles,
    bool? isSample,
    bool clearError = false,
  }) {
    return BattleState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      battles: battles ?? this.battles,
      isSample: isSample ?? this.isSample,
    );
  }
}
