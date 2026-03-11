import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/shimmer_loader.dart';
import '../../shared/widgets/step_indicator.dart';
import 'brands_controller.dart';
import 'widgets/brand_card.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BrandsController());
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.brandsTitle)),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Column(
              children: [
                StepIndicator(
                  currentStep: 2,
                  totalSteps: 3,
                  labels: ['Skin Tone', 'Brands', 'Results'],
                ),
                Expanded(child: ShimmerLoader(itemCount: 6)),
              ],
            );
          }

          return Column(
            children: [
              const StepIndicator(
                currentStep: 2,
                totalSteps: 3,
                labels: ['Skin Tone', 'Brands', 'Results'],
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.md,
                    AppSpacing.screenH,
                    AppSpacing.sm,
                  ),
                  itemCount: ctrl.brands.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.listGap),
                  itemBuilder: (_, i) => BrandCard(brand: ctrl.brands[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  AppSpacing.lg,
                ),
                child: Obx(() {
                  final bCount = ctrl.selectedBrands.length;
                  final sCount = ctrl.selectedShades.length;
                  final label = bCount == 0
                      ? 'Next - See Results'
                      : '$bCount brand${bCount > 1 ? "s" : ""}, $sCount shade${sCount > 1 ? "s" : ""} selected';
                  return FilledButton(
                    onPressed: ctrl.proceed,
                    child: Text(label),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
