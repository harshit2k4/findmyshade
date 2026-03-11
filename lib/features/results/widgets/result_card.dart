import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/constants/app_spacing.dart';
import '../results_controller.dart';
import 'share_card.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.item, required this.rank});

  final ResultItem item;
  final int rank;

  Color _onColor(Color bg) =>
      bg.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ResultsController>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = item.shade.color;
    final pct = (item.score * 100).toStringAsFixed(0);
    final isTop = rank == 1;

    // Get or create the screenshot controller for this shade
    final screenshotCtrl = ctrl.screenshotControllers
        .putIfAbsent(item.shade.id, () => ScreenshotController());

    return Stack(
      children: [
        // Invisible screenshot target — captured but never shown
        Positioned(
          left: -9999,
          top: -9999,
          child: Screenshot(
            controller: screenshotCtrl,
            child: ShareCard(item: item),
          ),
        ),

        // Visible card
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTop ? cs.primary : cs.outlineVariant,
              width: isTop ? 2 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left color panel
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(19),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            color: _onColor(color),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.shade.finish,
                        style: TextStyle(
                          color: _onColor(color).withOpacity(0.75),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Right info panel
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardInner),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row: best match badge + action buttons
                        Row(
                          children: [
                            if (isTop)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Best Match',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Favourite button
                            Obx(() {
                              final isFav = ctrl.isFavourite(item.shade.id);
                              return GestureDetector(
                                onTap: () =>
                                    ctrl.toggleFavourite(item.shade.id),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(isFav),
                                    size: 22,
                                    color: isFav
                                        ? Colors.redAccent
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(width: AppSpacing.sm),

                            // Share button
                            Obx(() => GestureDetector(
                                  onTap: ctrl.isSharing.value
                                      ? null
                                      : () => ctrl.shareResult(item.shade.id),
                                  child: Icon(
                                    Icons.ios_share_rounded,
                                    size: 20,
                                    color: cs.onSurfaceVariant,
                                  ),
                                )),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Shade name
                        Text(
                          item.shade.name,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 3),

                        // Brand name
                        Text(
                          item.brand.name,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Match bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: item.score,
                                  minHeight: 7,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isTop ? cs.primary : cs.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$pct%',
                              style: tt.labelMedium?.copyWith(
                                color: isTop ? cs.primary : cs.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
