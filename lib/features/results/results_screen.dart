import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/skin_tone_model.dart';
import '../../shared/widgets/step_indicator.dart';
import '../skin_tone/skin_tone_controller.dart';
import 'results_controller.dart';
import 'widgets/result_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ResultsController());
    final toneCtrl = Get.find<SkinToneController>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resultsTitle),
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            child: const Text('Start Over'),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.results.isEmpty) {
            return _EmptyState(cs: cs);
          }

          final tone = toneCtrl.selectedTone.value;

          return Column(
            children: [
              const StepIndicator(
                currentStep: 3,
                totalSteps: 3,
                labels: ['Skin Tone', 'Brands', 'Results'],
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Header row: tone chip + shade count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          AppSpacing.sm,
                          AppSpacing.screenH,
                          AppSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            if (tone != null) ...[
                              _ToneChip(tone: tone, cs: cs),
                              const Spacer(),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs + 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${ctrl.results.length} shades',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Result cards
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      sliver: SliverList.separated(
                        itemCount: ctrl.results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.listGap),
                        itemBuilder: (_, i) => ResultCard(
                          item: ctrl.results[i],
                          rank: i + 1,
                        ),
                      ),
                    ),

                    // Disclaimer card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          AppSpacing.lg,
                          AppSpacing.screenH,
                          AppSpacing.xl,
                        ),
                        child: _DisclaimerCard(cs: cs),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// Glassmorphism skin tone chip
class _ToneChip extends StatelessWidget {
  const _ToneChip({required this.tone, required this.cs});

  final SkinToneModel tone;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassOpacity =
        isDark ? AppTheme.glassOpacityDark : AppTheme.glassOpacityLight;
    final borderOpacity = isDark
        ? AppTheme.glassBorderOpacityDark
        : AppTheme.glassBorderOpacityLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.glassSigma,
          sigmaY: AppTheme.glassSigma,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(glassOpacity),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.primary.withOpacity(borderOpacity),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: tone.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant, width: 1),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                tone.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Disclaimer card shown below all results
class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardInner),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.disclaimerTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.disclaimerBody,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

// Empty state when no shades were selected
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_paint_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text('No shades to rank',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Go back and select at least one shade.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
