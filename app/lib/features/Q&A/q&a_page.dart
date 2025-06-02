// lib/features/questions/question_presenter_screen.dart
// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:app/features/Q&A/helpers/questions.dart';

class QuestionsAndAnswers extends StatefulWidget {
  const QuestionsAndAnswers({super.key});

  @override
  State<QuestionsAndAnswers> createState() => _QuestionsAndAnswersState();
}

class _QuestionsAndAnswersState extends State<QuestionsAndAnswers>
    with SingleTickerProviderStateMixin {
  late String selectedQuestion;
  bool showAnswerInput = false;
  Timer? autoTransitionTimer;

  @override
  void initState() {
    super.initState();
    selectedQuestion = _getRandomQuestion();
    _startAutoTransitionTimer();
  }

  @override
  void dispose() {
    autoTransitionTimer?.cancel();
    super.dispose();
  }

  void _startAutoTransitionTimer() {
    autoTransitionTimer?.cancel(); // Garante que só há um timer ativo
    autoTransitionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !showAnswerInput) {
        setState(() {
          showAnswerInput = true;
        });
      }
    });
  }

  String _getRandomQuestion() {
    final random = Random();
    return questionsPool[random.nextInt(questionsPool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (showAnswerInput) {
          setState(() {
            showAnswerInput = false;
          });
          await Future.delayed(const Duration(milliseconds: 600));
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Hero(
              tag: 'questionHero',
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: theme.colorScheme.primary,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!showAnswerInput) {
                  autoTransitionTimer?.cancel();
                  setState(() {
                    showAnswerInput = true;
                  });
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: showAnswerInput
                    ? _buildAnswerInput(context, theme)
                    : _buildPopupQuestion(context, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupQuestion(BuildContext context, ThemeData theme) {
    return Center(
      key: const ValueKey("questionPopup"),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 500),
        scale: 1.0,
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            selectedQuestion,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context, ThemeData theme) {
    return Padding(
      key: const ValueKey("answerInput"),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            selectedQuestion,
            textAlign: TextAlign.start,
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedQuestion = _getRandomQuestion();
                    showAnswerInput = false;
                  });
                  _startAutoTransitionTimer(); // Reinicia o timer
                },
                child: Text("More",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    )),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Aqui você pode enviar a resposta pro backend
                  Navigator.pop(context);
                },
                child: Text("Finish",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
