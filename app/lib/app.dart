import 'package:emosaic/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'features/home/home_screen.dart';

class EmosaicApp extends StatelessWidget {
  const EmosaicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'emosaic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeNotifier.seedColor),
      darkTheme: AppTheme.darkTheme(themeNotifier.seedColor),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
