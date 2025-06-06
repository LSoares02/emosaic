import 'dart:math';
import 'package:emosaic/features/home/home_screen.dart';
import 'package:emosaic/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayDetailsPage extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> qaBlocks;

  const DayDetailsPage({super.key, required this.date, required this.qaBlocks});

  Map<String, int> _countEmotions() {
    final Map<String, int> counts = {};
    for (final block in qaBlocks) {
      final List emotions = block['emotions'] ?? ['neutral'];
      for (final e in emotions) {
        counts[e['emotion']] = (counts[e['emotion']] ?? 0) + 1;
      }
    }
    return counts;
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final emotionCounts = _countEmotions();
    final random = Random();

    return WillPopScope(
      onWillPop: () async {
        _navigateToHome(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormat.MMMMd().format(date)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _navigateToHome(context),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final int totalEmotions = emotionCounts.length;
            final screenHeight =
                constraints.maxHeight -
                kToolbarHeight -
                MediaQuery.of(context).padding.top;

            final int crossAxisCount = (totalEmotions == 1) ? 1 : 2;

            // Distribui os blocos entre colunas
            final List<List<MapEntry<String, int>>> columns = List.generate(
              crossAxisCount,
              (_) => [],
            );
            for (int i = 0; i < totalEmotions; i++) {
              columns[i % crossAxisCount].add(
                emotionCounts.entries.elementAt(i),
              );
            }

            return Row(
              children: List.generate(crossAxisCount, (colIndex) {
                final entries = columns[colIndex];
                final List<double> factors = List.generate(
                  entries.length,
                  (_) => random.nextDouble() + 0.5,
                );
                final double totalFactor = factors.reduce((a, b) => a + b);

                return Expanded(
                  child: Column(
                    children: List.generate(entries.length, (i) {
                      final entry = entries[i];
                      final emotion = entry.key;
                      final color =
                          emotionColors[emotion]?['color'] ?? Colors.grey;
                      final height = screenHeight * (factors[i] / totalFactor);

                      return Container(
                        height: height,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              emotion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
