import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/api_service.dart';
import 'models/article_state.dart';

final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
  return ArticleNotifier();
});

class ArticleNotifier extends StateNotifier<ArticleState> {
  ArticleNotifier() : super(ArticleState()) {
    fetchArticles();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchArticles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final articleList = await _apiService.getArticles();
      state = state.copyWith(isLoading: false, articles: articleList);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Maqolalarni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> fetchArticleById(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final article = await _apiService.getArticleById(id);
      state = state.copyWith(isLoading: false, selectedArticle: article);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Maqola haqidagi ma'lumotni yuklashda xatolik yuz berdi!",
      );
    }
  }

  Future<void> increaseArticleView(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.increaseArticleView(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Ko'rishlar sonini oshirishda xatolik yuz berdi!", // Matn to'g'irlandi
      );
    }
  }
}