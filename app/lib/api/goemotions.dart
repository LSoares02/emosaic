import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> fetchEmotionsForAnswers(
  List<Map<String, dynamic>> qaBlocks,
) async {
  final url = Uri.parse('https://charmed-donkey-secure.ngrok-free.app/emotion');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'entries': qaBlocks, // Enviando os objetos completos
        'threshold': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      debugPrint('Failed to detect emotion: ${response.statusCode}');
      debugPrint(response.body);
      return null;
    }
  } catch (e) {
    debugPrint('Exception: $e');
    return null;
  }
}
