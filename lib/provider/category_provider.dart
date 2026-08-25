import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/api_service.dart';
import 'models/category_state.dart'; // Yo'lakni o'zingizdagi struktura bo'yicha to'g'rilang

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState()) {
    fetchCategories();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categoryList = await _apiService.getCategories();
      state = state.copyWith(isLoading: false, categories: categoryList);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: "Kategoriyalarni yuklashda xatolik yuz berdi!");
    }
  }

}