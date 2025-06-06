import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnTextChanged = void Function();

class AnswerInput extends StatelessWidget {
  final List<Map<String, dynamic>> qaBlocks;
  final List<TextEditingController> controllers;
  final OnTextChanged onTextChanged;
  final Future<void> Function() onAddQuestion;
  final VoidCallback onFinish;
  final Function(BuildContext) showShortAnswerWarning;
  final VoidCallback startAutoTransitionTimer;

  const AnswerInput({
    super.key,
    required this.qaBlocks,
    required this.controllers,
    required this.onTextChanged,
    required this.onAddQuestion,
    required this.onFinish,
    required this.showShortAnswerWarning,
    required this.startAutoTransitionTimer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                                            .withValues(alpha: 0.5)
                                      : theme.colorScheme.primaryContainer
                                            .withValues(alpha: .8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),
                        // if (qaBlocks.length < 3)
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 32),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                    (states) =>
                                        isLastAnswerEmpty ||
                                            !isCurrentAnswerValid
                                        ? theme.colorScheme.onPrimary
                                              .withValues(alpha: 0.5)
                                        : theme.colorScheme.onPrimary,
                                  ),
                              iconColor: WidgetStateProperty.all<Color>(
                                theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            onPressed: () async {
                              if (!isCurrentAnswerValid) {
                                showShortAnswerWarning(context);
                                return;
                              }
                              await onAddQuestion();
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
                            onPressed: () {
                              if (!isCurrentAnswerValid) {
                                showShortAnswerWarning(context);
                                return;
                              }
                              onFinish();
                            },
                            style: ButtonStyle(
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(vertical: 16),
                                  ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                    (states) =>
                                        isAnyAnswerEmpty ||
                                            !isCurrentAnswerValid
                                        ? theme.colorScheme.onPrimary
                                              .withValues(alpha: 0.5)
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
