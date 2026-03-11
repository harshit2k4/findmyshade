import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  final int currentStep; // 1-indexed
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          // Even indices are step circles, odd are connectors
          if (i.isOdd)
            return _Connector(filled: (i ~/ 2) < currentStep - 1, cs: cs);

          final step = i ~/ 2 + 1;
          return _StepDot(
            step: step,
            label: labels[i ~/ 2],
            state: step < currentStep
                ? _DotState.done
                : step == currentStep
                ? _DotState.active
                : _DotState.idle,
            cs: cs,
          );
        }),
      ),
    );
  }
}

enum _DotState { done, active, idle }

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.label,
    required this.state,
    required this.cs,
  });

  final int step;
  final String label;
  final _DotState state;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _DotState.done;
    final isActive = state == _DotState.active;

    final bgColor = isDone || isActive
        ? cs.primary
        : cs.surfaceContainerHighest;
    final fgColor = isDone || isActive ? cs.onPrimary : cs.onSurfaceVariant;
    final labelColor = isActive
        ? cs.primary
        : isDone
        ? cs.onSurfaceVariant
        : cs.onSurfaceVariant.withOpacity(0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 34 : 28,
          height: isActive ? 34 : 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, size: 15, color: fgColor)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: isActive ? 14 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: labelColor,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.filled, required this.cs});

  final bool filled;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md + AppSpacing.xs),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 2,
          decoration: BoxDecoration(
            color: filled ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
