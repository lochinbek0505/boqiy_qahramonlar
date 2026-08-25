
import 'package:boqiy_qahramonlar/models/category_models.dart';
class CategoryState {
  final bool isLoading;
  final String? error;
  final List<CategoryModel> categories;

  CategoryState({this.isLoading = false, this.error, this.categories = const []});

  CategoryState copyWith({bool? isLoading, String? error, List<CategoryModel>? categories}) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
    );
  }
}
