import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class QuillUtils {
  static String parseDeltaToPlainText(String? content) {
    if (content == null || content.isEmpty) return "";
    try {
      final doc = Document.fromJson(jsonDecode(content));
      return doc.toPlainText().trim();
    } catch (e) {
      return content; // If it's not a valid JSON, return as is
    }
  }
}
