import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        Text(
                          AppStrings.skinToneSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Pick your tone',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 14),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
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

                        const SizedBox(height: 32),

                        Text(
                          'Or detect from a photo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 14),

                        Obx(
                          () => PhotoUploadCard(
                            onPick: ctrl.pickImage,
                            pickedImage: ctrl.pickedImage.value,
                            isDetecting: ctrl.isDetecting.value,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Button always pinned to bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
