import '../../models/article_model.dart';

class ArticleState {
  final bool isLoading;
  final String? error;
  final List<ArticleModel> articles;
  final List<ArticleModel> authorArticles;
  final List<ArticleModel> mostReadArticles;
  final ArticleModel? selectedArticle;

  ArticleState({
    this.isLoading = false,
    this.error,
    this.articles = const [],
    this.authorArticles = const [],
    this.mostReadArticles = const [],
    this.selectedArticle,
  });

  ArticleState copyWith({
    bool? isLoading,
    String? error,
    List<ArticleModel>? articles,
    List<ArticleModel>? authorArticles,
    List<ArticleModel>? mostReadArticles,
    ArticleModel? selectedArticle,
    bool clearError = false,
  }) {
    return ArticleState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      articles: articles ?? this.articles,
      authorArticles: authorArticles ?? this.authorArticles,
      mostReadArticles: mostReadArticles ?? this.mostReadArticles,
      selectedArticle: selectedArticle ?? this.selectedArticle,
    );
  }
}
