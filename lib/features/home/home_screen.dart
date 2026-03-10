import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background color
          _Background(cs: cs),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Lip icon inside a glass card
                  _GlassIcon(cs: cs, isDark: isDark),
                  const SizedBox(height: 36),
                  // App name
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Tagline
                  Text(
                    AppStrings.tagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  // Get started button
                  FilledButton(
                    onPressed: () => Get.toNamed(AppRoutes.skinTone),
                    child: const Text(AppStrings.getStarted),
                  ),
                  const SizedBox(height: 36),
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
          colors: [cs.primaryContainer, cs.surface, cs.secondaryContainer],
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
    final glassOpacity = isDark
        ? AppTheme.glassOpacityDark
        : AppTheme.glassOpacityLight;
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
          child: Icon(Icons.format_paint_rounded, size: 56, color: cs.primary),
        ),
      ),
    );
  }
}
