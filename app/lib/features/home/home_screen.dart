import 'dart:math';
import 'package:app/features/Q&A/q&a_page.dart';
import 'package:app/features/info_page/info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String day;
  late String month;
  late String prompt;

  final List<String> prompts = [
    "How am I feeling?",
    "Thinking about...",
    "Write it down",
    "Tap to reflect",
    "What's on your mind?",
  ];

  @override
  void initState() {
    super.initState();

    // Captura a data atual formatada
    final now = DateTime.now();
    day = DateFormat('dd').format(now); // ex: 01
    month = DateFormat('MMMM').format(now); // ex: June

    // Sorteia uma frase aleatória
    final random = Random();
    prompt = prompts[random.nextInt(prompts.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'emosaic',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 12),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InfoPage(),
                  ),
                );
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Data
            Text(
              day,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              month,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (_, __, ___) => const QuestionsAndAnswers(),
                      opaque: true,
                    ),
                  );
                },
                child: Hero(
                  tag: 'questionHero',
                  child: Material(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        prompt,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: () {
                  // Ação do histórico
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "See past days",
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
