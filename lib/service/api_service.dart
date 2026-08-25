import 'package:boqiy_qahramonlar/models/category_models.dart';
import 'package:dio/dio.dart';

import '../models/article_model.dart';
import '../models/hashteg_model.dart';
import '../models/history_model.dart';
import '../models/poems_model.dart';

class ApiService {
  late Dio _dio;

  final String _baseUrl = "https://api.boqiyqahramonlar.uz/api/v1/";

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<List<CategoryModels>> getCategories() async {
    try {
      var response = await _dio.get("category");
      return (response.data as List)
          .map((x) => CategoryModels.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ArticleModel?> getArticleById(int id) async {
    try {
      var response = await _dio.get("articles/$id");
      return ArticleModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> increaseArticleView(int id) async {
    try {
      await _dio.post("articles/$id/view");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ArticleModel>> getArticles({
    String? author,
    String? category,
    String? tag,
    String? sort,
  }) async {
    try {
      var response = await _dio.get(
        "articles",
        queryParameters: {
          if (author != null) 'author': author,
          if (category != null) 'category': category,
          if (tag != null) 'tag': tag,
          if (sort != null) 'sort': sort,
        },
      );
      return (response.data as List)
          .map((x) => ArticleModel.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PoemsModel>> getPoems({
    String? author,
    String? tag,
    String? sort,
  }) async {
    try {
      var response = await _dio.get(
        "poems/getEditor",
        queryParameters: {
          if (author != null) 'author': author,
          if (tag != null) 'tag': tag,
          if (sort != null) 'sort': sort,
        },
      );
      return (response.data as List)
          .map((x) => PoemsModel.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<PoemsModel?> getPoemById(int id) async {
    try {
      var response = await _dio.get("poems/$id");
      return PoemsModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> increasePoemView(int id) async {
    try {
      await _dio.post("poems/$id/view");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<HistoryModel>> getHistories({
    String? author,
    String? tag,
    String? sort,
  }) async {
    try {
      var response = await _dio.get(
        "history/getEditor",
        queryParameters: {
          if (author != null) 'author': author,
          if (tag != null) 'tag': tag,
          if (sort != null) 'sort': sort,
        },
      );
      return (response.data as List)
          .map((x) => HistoryModel.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<HistoryModel?> getHistoryById(int id) async {
    try {
      var response = await _dio.get("history/$id");
      return HistoryModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> increaseHistoryView(int id) async {
    try {
      await _dio.post("history/$id/view");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<CategoryModels?> getCategoryById(int id) async {
    try {
      var response = await _dio.get("category/$id");
      return CategoryModels.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<HashtegModel>> getHashtags() async {
    try {
      var response = await _dio.get("hashteg");
      return (response.data as List)
          .map((x) => HashtegModel.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<HashtegModel?> getHashtagById(int id) async {
    try {
      var response = await _dio.get("hashteg/$id");
      return HashtegModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
