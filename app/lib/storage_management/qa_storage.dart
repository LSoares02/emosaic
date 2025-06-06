import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class QAStorage {
  static String _keyForDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return 'qa_blocks_${formatter.format(date)}';
  }

  /// Salva os blocos de Q&A para a data atual
  static Future<void> saveQABlocks(
    List<Map<String, dynamic>> qaBlocks, [
    DateTime? date,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date ?? DateTime.now());
    final encoded = jsonEncode(qaBlocks);
    await prefs.setString(key, encoded);
  }

  /// Carrega os blocos de Q&A para a data atual
  static Future<List<Map<String, dynamic>>> loadQABlocks([
    DateTime? date,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date ?? DateTime.now());
    final saved = prefs.getString(key);
    if (saved != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(saved));
    }
    return [];
  }

  /// Carrega as perguntas recentes de uma quantidade de dias
  static Future<Set<String>> getRecentQuestionsFromLastDays({
    int days = 3,
  }) async {
    final Set<String> recentQuestions = {};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final qaBlocks = await loadQABlocks(date);
      for (final block in qaBlocks) {
        final question = block["question"];
        if (question is String) {
          recentQuestions.add(question);
        }
      }
    }

    return recentQuestions;
  }

  /// Apaga os blocos de Q&A de uma data específica
  static Future<void> clearQABlocks([DateTime? date]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date ?? DateTime.now());
    await prefs.remove(key);
  }

  /// Lista todas as chaves de Q&A armazenadas (útil para histórico)
  static Future<List<String>> listSavedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final qaKeys = keys.where((k) => k.startsWith('qa_blocks_')).toList();
    return qaKeys;
  }
}
