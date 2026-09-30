import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/api_service.dart';
import 'models/history_state.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState()) {
    fetchHistories();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchHistories({
    String? author,
    String? tag,
    String? sort,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final historyList = await _apiService.getHistories(
        author: author,
        tag: tag,
        sort: sort,
      );
      state = state.copyWith(isLoading: false, histories: historyList);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Tarixiy voqealarni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> fetchAuthorHistories(String author) async {
    try {
      final historyList = await _apiService.getHistories(author: author);
      state = state.copyWith(authorHistories: historyList);
    } catch (e) {
      //
    }
  }

  Future<void> fetchMostReadHistories() async {
    try {
      final historyList = await _apiService.getHistories(sort: 'view_count');
      state = state.copyWith(mostReadHistories: historyList);
    } catch (e) {
      //
    }
  }

  Future<void> fetchHistoryById(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final history = await _apiService.getHistoryById(id);
      state = state.copyWith(isLoading: false, selectedHistory: history);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Tarix haqidagi ma'lumotni yuklashda xatolik yuz berdi!",
      );
    }
  }


  Future<void> increaseHistoryView(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.increaseHistoryView(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Ko'rishlar sonini oshirishda xatolik yuz berdi!", // Matn to'g'irlandi
      );
    }
  }
}