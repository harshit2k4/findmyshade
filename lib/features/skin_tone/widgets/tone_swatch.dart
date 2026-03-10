import 'package:flutter/material.dart';
import '../../../data/models/skin_tone_model.dart';

class ToneSwatch extends StatelessWidget {
  const ToneSwatch({
    super.key,
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  final SkinToneModel tone;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: tone.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: cs.primary.withOpacity(0.45), blurRadius: 12)]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tone name on a semi-transparent strip at bottom
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.28),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(17),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Text(
                    tone.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    tone.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
