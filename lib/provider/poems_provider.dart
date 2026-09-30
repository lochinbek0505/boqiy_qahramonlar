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

  Future<void> fetchPoems({
    String? author,
    String? tag,
    String? sort,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final poemsList = await _apiService.getPoems(
        author: author,
        tag: tag,
        sort: sort,
      );
      state = state.copyWith(isLoading: false, poems: poemsList);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "She'rlarni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> fetchAuthorPoems(String author) async {
    try {
      final poemsList = await _apiService.getPoems(author: author);
      state = state.copyWith(authorPoems: poemsList);
    } catch (e) {
      //
    }
  }

  Future<void> fetchMostReadPoems() async {
    try {
      final poemsList = await _apiService.getPoems(sort: 'view_count');
      state = state.copyWith(mostReadPoems: poemsList);
    } catch (e) {
      //
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