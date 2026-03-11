import 'package:flutter/material.dart';
import '../../../data/models/brand_model.dart';

class ShadeChip extends StatelessWidget {
  const ShadeChip({
    super.key,
    required this.shade,
    required this.isSelected,
    required this.onTap,
  });

  final ShadeModel shade;
  final bool isSelected;
  final VoidCallback onTap;

  // Returns black or white depending on shade color luminance
  Color _labelColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.35 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          // Always use surface as background, never the shade color
          color: isSelected ? cs.surfaceContainerHighest : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color swatch circle with check
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: shade.color,
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant, width: 0.5),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: _labelColor(shade.color),
                    )
                  : null,
            ),
            const SizedBox(width: 8),

            // Name and finish always use theme colors, never shade color
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shade.name,
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface, // always readable
                  ),
                ),
                Text(
                  shade.finish,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
