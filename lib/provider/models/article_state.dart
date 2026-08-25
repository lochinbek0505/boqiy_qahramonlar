import '../../models/article_model.dart';

class ArticleState {
  final bool isLoading;
  final String? error;
  final List<ArticleModel> articles;
  final ArticleModel? selectedArticle;

  ArticleState({
    this.isLoading = false,
    this.error,
    this.articles = const [],
    this.selectedArticle,
  });

  ArticleState copyWith({
    bool? isLoading,
    String? error,
    List<ArticleModel>? articles,
    ArticleModel? selectedArticle,
    bool clearError = false,
  }) {
    return ArticleState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle ?? this.selectedArticle,
    );
  }
}