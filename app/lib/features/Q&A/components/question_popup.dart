import 'package:flutter/material.dart';

class QuestionPopup extends StatelessWidget {
  final String currentQuestion;
  final int remainingSeconds;
  final bool showLoading;

  const QuestionPopup({
    super.key,
    required this.currentQuestion,
    required this.remainingSeconds,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              child: showLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
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
          showLoading
              ? SizedBox(height: 32)
              : Row(
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
}
