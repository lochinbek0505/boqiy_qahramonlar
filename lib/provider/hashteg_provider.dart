import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/api_service.dart';
import 'models/hashteg_state.dart'; // Yo'lakni to'g'rilang

final hashtegProvider = StateNotifierProvider<HashtegNotifier, HashtegState>((
  ref,
) {
  return HashtegNotifier();
});

class HashtegNotifier extends StateNotifier<HashtegState> {
  HashtegNotifier() : super(HashtegState()) {
    fetchHashtegs();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchHashtegs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hashtegList = await _apiService.getHashtags();
      state = state.copyWith(isLoading: false, hashtegs: hashtegList);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Hashteglarni yuklashda xatolik yuz berdi!",
      );
    }
  }

}
