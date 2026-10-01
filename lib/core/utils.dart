import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class QuillUtils {
  // Kartalar har rebuild'da (provider o'zgarishi, tema, o'lcham) butun Quill
  // JSON'ini qayta parse qilardi — natija keshlanadi.
  static final _cache = <String, String>{};
  static const _cacheLimit = 300;

  static String parseDeltaToPlainText(String? content) {
    if (content == null || content.isEmpty) return "";
    final cached = _cache[content];
    if (cached != null) return cached;
    String result;
    try {
      final doc = Document.fromJson(jsonDecode(content));
      result = doc.toPlainText().trim();
    } catch (e) {
      result = content; // If it's not a valid JSON, return as is
    }
    if (_cache.length >= _cacheLimit) _cache.remove(_cache.keys.first);
    _cache[content] = result;
    return result;
  }
}
