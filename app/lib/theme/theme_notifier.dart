// lib/core/theme/theme_notifier.dart
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  Color _seedColor = Colors.blue;

  Color get seedColor => _seedColor;

  void updateColor(Color newColor) {
    debugPrint('Updating seed color to: $newColor');
    _seedColor = newColor;
    notifyListeners();
  }
}
