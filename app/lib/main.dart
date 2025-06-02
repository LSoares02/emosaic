import 'package:app/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const EmosaicApp(),
    ),
  );
}
