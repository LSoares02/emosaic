// lib/features/questions/question_presenter_screen.dart
// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:emosaic/features/Q&A/helpers/questions.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();

    qaBlocks.add({
      "question": _getRandomQuestion(),
      "answer": "",
      "emotions": [],
    });

    final controller = TextEditingController();
    controller.addListener(_onTextChanged);
    controllers.add(controller);

    // Espera o Hero terminar para liberar a opacidade do conteúdo inicial
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !showAnswerInput) {
        setState(() {
          showPopupOpacity = true;
        });
      }
    });

    _startAutoTransitionTimer();
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
      setState(() {});
    }
  }

  void showShortAnswerWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Give me a bit more..."),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  String _getRandomQuestion() {
    final random = Random();
    return questionsPool[random.nextInt(questionsPool.length)];
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
                      ? _buildAnswerInput(context, theme)
                      : _buildPopupQuestion(context, theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupQuestion(BuildContext context, ThemeData theme) {
    final currentQuestion = qaBlocks.isNotEmpty
        ? qaBlocks.last["question"] as String
        : "";

    return Center(
      key: const ValueKey("questionPopup"),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: 1.0,
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                currentQuestion,
                textAlign: TextAlign.left,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: remainingSeconds > index ? 1.0 : 0.2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context, ThemeData theme) {
    final isLastAnswerEmpty = controllers.isNotEmpty
        ? controllers.last.text.trim().isEmpty
        : true;

    final isAnyAnswerEmpty = controllers.any((c) => c.text.trim().isEmpty);
    final isCurrentAnswerValid = controllers.last.text.trim().length >= 20;

    return Padding(
      key: const ValueKey("answerInput"),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    Column(
                      children: [
                        ...List.generate(qaBlocks.length, (index) {
                          final block = qaBlocks[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                block["question"],
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],

                                controller: controllers[index],
                                maxLines: 1,
                                readOnly: index != controllers.length - 1,
                                decoration: InputDecoration(
                                  hintText: "Feelings, thoughts...",
                                  filled: true,
                                  fillColor: index != controllers.length - 1
                                      ? theme.colorScheme.primaryContainer
                                            .withOpacity(0.5)
                                      : theme.colorScheme.primaryContainer
                                            .withOpacity(.8),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),
                        if (qaBlocks.length < 3)
                          Center(
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 32),

                              style: ButtonStyle(
                                backgroundColor:
                                    isLastAnswerEmpty || !isCurrentAnswerValid
                                    ? WidgetStateProperty.all(
                                        theme.colorScheme.onPrimary.withOpacity(
                                          0.5,
                                        ),
                                      )
                                    : WidgetStateProperty.all(
                                        theme.colorScheme.onPrimary,
                                      ),

                                iconColor: WidgetStateProperty.all(
                                  theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              onPressed:
                                  !isCurrentAnswerValid || isLastAnswerEmpty
                                  ? () {
                                      final currentText = controllers.last.text
                                          .trim();
                                      if (currentText.length < 30) {
                                        showShortAnswerWarning(context);
                                        return;
                                      }
                                    }
                                  : () {
                                      final lastController = controllers.last;
                                      if (lastController.text.trim().isEmpty)
                                        return;

                                      _startAutoTransitionTimer();
                                      setState(() {
                                        qaBlocks.last["answer"] = lastController
                                            .text
                                            .trim();
                                        qaBlocks.add({
                                          "question": _getRandomQuestion(),
                                          "answer": "",
                                          "emotions": [],
                                        });
                                        controllers.add(
                                          TextEditingController()
                                            ..addListener(_onTextChanged),
                                        );
                                        showAnswerInput = false;
                                      });
                                    },
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: isAnyAnswerEmpty || !isCurrentAnswerValid
                                ? () {
                                    final currentText = controllers.last.text
                                        .trim();
                                    if (currentText.length < 30) {
                                      showShortAnswerWarning(context);
                                      return;
                                    }
                                  }
                                : () {
                                    safePop(context);
                                  },
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(vertical: 16),
                              ),
                              backgroundColor: WidgetStateProperty.all(
                                isAnyAnswerEmpty || !isCurrentAnswerValid
                                    ? theme.colorScheme.onPrimary.withOpacity(
                                        0.5,
                                      )
                                    : theme.colorScheme.onPrimary,
                              ),
                            ),
                            child: Text(
                              "Finish",
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
