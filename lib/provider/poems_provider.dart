import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/api_service.dart';
import 'models/poem_state.dart';

final poemsProvider = StateNotifierProvider<PoemsNotifier, PoemsState>((ref) {
  return PoemsNotifier();
});

class PoemsNotifier extends StateNotifier<PoemsState> {
  PoemsNotifier() : super(PoemsState()) {
    fetchPoems();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchPoems() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final poemsList = await _apiService.getPoems();
      state = state.copyWith(isLoading: false, poems: poemsList);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "She'rlarni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> fetchPoemById(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final poem = await _apiService.getPoemById(id);
      state = state.copyWith(isLoading: false, selectedPoem: poem);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "She'r haqidagi ma'lumotni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> increasePoems(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.increasePoemView(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Ko'rishlar sonini oshirishda xatolik yuz berdi!", // Matn to'g'irlandi
      );
    }
  }
}