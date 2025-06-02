import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String?> fetchColorName(String hexColor) async {
  // Garante que estamos pegando apenas os 6 primeiros caracteres (RGB)
  final cleanHexColor =
      hexColor.length > 6 ? hexColor.substring(2, 8) : hexColor;

  final url = Uri.parse('https://www.thecolorapi.com/id?hex=$cleanHexColor');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name']['value'] as String?;
    } else {
      debugPrint('Failed to load color name');
      return '-';
    }
  } catch (e) {
    debugPrint(e.toString());
    return '-';
  }
}

Future<Map<String, dynamic>?> fetchColorScheme(
  String hexColor,
  String mode,
) async {
  // Garante que estamos pegando apenas os 6 primeiros caracteres (RGB)
  final cleanHexColor =
      hexColor.length > 6 ? hexColor.substring(2, 8) : hexColor;

  final url = Uri.parse(
    'https://www.thecolorapi.com/scheme?hex=$cleanHexColor&mode=$mode&count=4',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      debugPrint('Failed to load color name');
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
