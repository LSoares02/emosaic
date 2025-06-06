// lib/features/questions/question_presenter_screen.dart
// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:emosaic/api/goemotions.dart';
import 'package:emosaic/features/day_details/day_details.dart'
    show DayDetailsPage;
import 'package:emosaic/storage_management/qa_storage.dart';
import 'package:flutter/material.dart';
import 'package:emosaic/features/Q&A/helpers/questions.dart';
import 'components/question_popup.dart';
import 'components/answer_input.dart';

class QuestionsAndAnswers extends StatefulWidget {
  const QuestionsAndAnswers({super.key});

  @override
  State<QuestionsAndAnswers> createState() => _QuestionsAndAnswersState();
}

class _QuestionsAndAnswersState extends State<QuestionsAndAnswers>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> qaBlocks = [];
  final List<TextEditingController> controllers = [];

  bool showAnswerInput = false;
  Timer? autoTransitionTimer;
  int remainingSeconds = 3;
  bool showPopupOpacity = false;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();

    // Start with an empty question, we'll update it when we get the real one
    qaBlocks.add({
      "question": "Loading...", // Placeholder
      "answer": "",
      "emotions": [],
    });

    final controller = TextEditingController();
    controller.addListener(_onTextChanged);
    controllers.add(controller);

    // Load the initial question
    _loadInitialQuestion();

    // Start the auto transition timer
    _startAutoTransitionTimer();

    // Wait for the Hero animation to finish
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showPopupOpacity = true;
        });
      }
    });
  }

  // New method to load the initial question
  Future<void> _loadInitialQuestion() async {
    final question = await _getRandomQuestion();
    if (mounted) {
      setState(() {
        qaBlocks[0]["question"] = question;
      });
    }
  }

  @override
  void dispose() {
    autoTransitionTimer?.cancel();
    super.dispose();
  }

  void _startAutoTransitionTimer() {
    autoTransitionTimer?.cancel();
    remainingSeconds = 3;

    autoTransitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || showAnswerInput) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          showAnswerInput = true;
        });
      }
    });
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        // Update the answer for the current question
        for (int i = 0; i < controllers.length; i++) {
          if (i < qaBlocks.length) {
            qaBlocks[i]['answer'] = controllers[i].text;
          }
        }
      });
    }
  }

  void showShortAnswerWarning(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: const Text("Give me a bit more...")));
  }

  void safePop(BuildContext context) {
    setState(() {
      showAnswerInput = false;
      showPopupOpacity = false;
    });

    // Deixa a animação acontecer ao mesmo tempo que o pop
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<String> _getRandomQuestion() async {
    final random = Random();

    // Get recent questions from storage
    final recentQuestionsFromStorage =
        await QAStorage.getRecentQuestionsFromLastDays(days: 3);

    // Get questions from current session
    final currentSessionQuestions = qaBlocks
        .map((block) => block["question"] as String)
        .where((q) => q.isNotEmpty && q != "Loading...")
        .toList();

    // Combine both lists and remove duplicates
    final allRecentQuestions = {
      ...recentQuestionsFromStorage,
      ...currentSessionQuestions,
    }.toList();

    // Filter out questions that have been asked recently
    final available = questionsPool
        .where((q) => !allRecentQuestions.contains(q))
        .toList();

    if (available.isEmpty) {
      // If all questions have been used recently, fall back to any question
      return questionsPool[random.nextInt(questionsPool.length)];
    } else {
      return available[random.nextInt(available.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (showAnswerInput || showPopupOpacity) {
          setState(() {
            showAnswerInput = false;
            showPopupOpacity = false;
          });
          await Future.delayed(const Duration(milliseconds: 300));
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
            AnimatedOpacity(
              opacity: showAnswerInput || showPopupOpacity ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!showAnswerInput &&
                      autoTransitionTimer?.isActive == true) {
                    autoTransitionTimer?.cancel();
                    setState(() {
                      showAnswerInput = true;
                    });
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showAnswerInput
                      ? _buildAnswerInput(context)
                      : _buildPopupQuestion(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupQuestion(BuildContext context) {
    return QuestionPopup(
      currentQuestion: qaBlocks.isNotEmpty
          ? qaBlocks.last["question"] as String
          : "",
      remainingSeconds: remainingSeconds,
      showLoading: showLoading,
    );
  }

  Widget _buildAnswerInput(BuildContext context) {
    return AnswerInput(
      qaBlocks: qaBlocks,
      controllers: controllers,
      onTextChanged: _onTextChanged,
      onAddQuestion: () async {
        final newQuestion = await _getRandomQuestion();
        if (!mounted) return;

        setState(() {
          qaBlocks.last["answer"] = controllers.last.text.trim();
          qaBlocks.add({"question": newQuestion, "answer": "", "emotions": []});
          controllers.add(TextEditingController()..addListener(_onTextChanged));
          showAnswerInput = false;
        });
        _startAutoTransitionTimer();
      },
      onFinish: () async {
        setState(() {
          showLoading = true;
          showAnswerInput = false;
        });

        try {
          // 1. Fetch emotions for answers
          final emotionsList = await fetchEmotionsForAnswers(qaBlocks);
          debugPrint(emotionsList.toString());
          if (emotionsList == null) {
            throw Exception('Failed to fetch emotions');
          }

          // 2. Update qaBlocks with emotions
          for (int i = 0; i < qaBlocks.length; i++) {
            if (i < emotionsList.length) {
              qaBlocks[i] = emotionsList[i];
            }
          }

          // 3. Save qaBlocks to storage
          await QAStorage.saveQABlocks(qaBlocks);

          // 4. Navigate back to home screen
          if (mounted) {
            // Exemplo para abrir a página
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DayDetailsPage(date: DateTime.now(), qaBlocks: qaBlocks),
              ),
            );
          }

          // Testing errors:
          // await Future.delayed(const Duration(seconds: 2));
          // throw Exception('Failed to fetch emotions');
        } catch (e) {
          debugPrint('Error in onFinish: $e');
          if (mounted) {
            setState(() {
              showAnswerInput = true;
              showLoading = false;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Server fail')));
          }
        }
      },
      showShortAnswerWarning: showShortAnswerWarning,
      startAutoTransitionTimer: _startAutoTransitionTimer,
    );
  }
}
