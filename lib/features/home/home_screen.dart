import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          _Background(cs: cs),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: Column(
                children: [
                  // Saved shades button top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: IconButton.filledTonal(
                        onPressed: () => Get.toNamed(AppRoutes.saved),
                        icon: const Icon(Icons.favorite_rounded),
                        tooltip: 'Saved shades',
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Glass icon
                  _GlassIcon(cs: cs, isDark: isDark),

                  const SizedBox(height: AppSpacing.xl),

                  // App name
                  Text(
                    AppStrings.appName,
                    style: tt.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Tagline
                  Text(
                    AppStrings.tagline,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // CTA button
                  FilledButton(
                    onPressed: () => Get.toNamed(AppRoutes.skinTone),
                    child: const Text(AppStrings.getStarted),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Made with love footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.madeWith,
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite_rounded,
                          size: 13, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(AppStrings.madeBy,
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.surface,
            cs.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.cs, required this.isDark});

  final ColorScheme cs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final glassOpacity =
        isDark ? AppTheme.glassOpacityDark : AppTheme.glassOpacityLight;
    final borderOpacity = isDark
        ? AppTheme.glassBorderOpacityDark
        : AppTheme.glassBorderOpacityLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.glassSigma,
          sigmaY: AppTheme.glassSigma,
        ),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(glassOpacity),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: cs.primary.withOpacity(borderOpacity),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.format_paint_rounded,
            size: 56,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}
