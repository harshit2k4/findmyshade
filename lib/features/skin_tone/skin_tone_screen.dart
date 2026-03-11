import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/step_indicator.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/skin_tone_model.dart';
import 'skin_tone_controller.dart';
import 'widgets/tone_swatch.dart';
import 'widgets/photo_upload_card.dart';

class SkinToneScreen extends StatelessWidget {
  const SkinToneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SkinToneController());
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.skinToneTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossCount = width < 400
                ? 2
                : width < 700
                ? 3
                : 4;
            final swatchH = width < 400 ? 100.0 : 120.0;

            return Column(
              children: [
                const StepIndicator(
                  currentStep: 1,
                  totalSteps: 3,
                  labels: ['Skin Tone', 'Brands', 'Results'],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppStrings.skinToneSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Pick your tone',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio:
                                    width / (crossCount * swatchH),
                              ),
                          itemCount: indianSkinTones.length,
                          itemBuilder: (_, i) {
                            final tone = indianSkinTones[i];
                            return Obx(
                              () => ToneSwatch(
                                tone: tone,
                                isSelected:
                                    ctrl.selectedTone.value?.id == tone.id,
                                onTap: () => ctrl.selectTone(tone),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Or detect from a photo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Obx(
                          () => PhotoUploadCard(
                            onPick: ctrl.pickImage,
                            pickedImage: ctrl.pickedImage.value,
                            isDetecting: ctrl.isDetecting.value,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.sm,
                    AppSpacing.screenH,
                    AppSpacing.lg,
                  ),
                  child: FilledButton(
                    onPressed: ctrl.proceed,
                    child: const Text('Next - Pick Brands'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
