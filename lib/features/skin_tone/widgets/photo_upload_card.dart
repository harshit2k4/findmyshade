import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class PhotoUploadCard extends StatelessWidget {
  const PhotoUploadCard({
    super.key,
    required this.onPick,
    this.pickedImage,
    this.isDetecting = false,
  });

  final void Function(ImageSource) onPick;
  final File? pickedImage;
  final bool isDetecting;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassOpacity = isDark
        ? AppTheme.glassOpacityDark
        : AppTheme.glassOpacityLight;
    final borderOpacity = isDark
        ? AppTheme.glassBorderOpacityDark
        : AppTheme.glassBorderOpacityLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppTheme.glassSigma,
              sigmaY: AppTheme.glassSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(glassOpacity),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.primary.withOpacity(borderOpacity),
                  width: 1.5,
                ),
              ),
              child: isDetecting
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : pickedImage != null
                  ? _ImagePreview(image: pickedImage!, onPick: onPick)
                  : _PickerOptions(onPick: onPick),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Privacy note
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                AppStrings.privacyNote,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Two source buttons shown inside the glass card
class _PickerOptions extends StatelessWidget {
  const _PickerOptions({required this.onPick});
  final void Function(ImageSource) onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: _SourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: () => onPick(ImageSource.camera),
              cs: cs,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: cs.outlineVariant.withOpacity(0.5),
          ),
          Expanded(
            child: _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: () => onPick(ImageSource.gallery),
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: cs.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'tap to select',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onPick});

  final File image;
  final void Function(ImageSource) onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
          child: Image.file(image, width: 110, height: 110, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.toneDetected,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MiniButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Retake',
                    onTap: () => onPick(ImageSource.camera),
                    cs: cs,
                  ),
                  const SizedBox(width: 8),
                  _MiniButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => onPick(ImageSource.gallery),
                    cs: cs,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.onPrimaryContainer),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
