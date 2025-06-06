import 'package:emosaic/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const EmosaicApp(),
    ),
  );
}
