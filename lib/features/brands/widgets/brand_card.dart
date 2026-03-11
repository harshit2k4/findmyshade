import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/brand_model.dart';
import '../brands_controller.dart';
import 'shade_chip.dart';

class BrandCard extends StatelessWidget {
  const BrandCard({super.key, required this.brand});
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BrandsController>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Obx(() {
      final isSelected = ctrl.selectedBrands.contains(brand.id);
      final shadeCount = ctrl.selectedShadeCountFor(brand.id);

      return Container(
        decoration: BoxDecoration(
          // Neutral surface, border signals selection
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Brand header ──────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ctrl.toggleBrand(brand.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Color dot strip preview
                    SizedBox(
                      width: 56,
                      height: 26,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = 0; i < brand.shades.take(4).length; i++)
                            Positioned(
                              left: i * 12.0,
                              top: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: brand.shades[i].color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.surfaceContainerLow,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Brand info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand.name,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            brand.type,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right side: badge or checkbox
                    if (isSelected && shadeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$shadeCount shade${shadeCount > 1 ? "s" : ""}',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    const SizedBox(width: 8),

                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? cs.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outline,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: cs.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            // ── Shade picker (auto-expands on select) ────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withOpacity(0.5),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    size: 15,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tap the shades you own',
                                    style: tt.labelMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: brand.shades
                                    .map(
                                      (shade) => Obx(
                                        () => ShadeChip(
                                          shade: shade,
                                          isSelected: ctrl.selectedShades
                                              .contains(shade.id),
                                          onTap: () =>
                                              ctrl.toggleShade(shade.id),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}
