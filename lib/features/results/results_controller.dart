import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

import '../../data/local/favourites_box.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/skin_tone_model.dart';
import '../brands/brands_controller.dart';
import '../skin_tone/skin_tone_controller.dart';
import '../../shared/widgets/app_snackbar.dart';

class ResultItem {
  final ShadeModel shade;
  final BrandModel brand;
  final double score;

  const ResultItem({
    required this.shade,
    required this.brand,
    required this.score,
  });
}

// Ideal lip shades per Indian skin tone (makeup artist guidelines)
const _idealShades = {
  'fair': [Color(0xFFE8829A), Color(0xFFC05070), Color(0xFFD4607A)],
  'wheatish_light': [Color(0xFFC04060), Color(0xFFB03050), Color(0xFFD05870)],
  'wheatish': [Color(0xFFB03050), Color(0xFF9A2840), Color(0xFFC04868)],
  'medium': [Color(0xFFA02840), Color(0xFF882030), Color(0xFFB04050)],
  'dusky': [Color(0xFF882030), Color(0xFF6A1828), Color(0xFF9A2838)],
  'deep': [Color(0xFF6A1828), Color(0xFF5A1020), Color(0xFF882030)],
};

class ResultsController extends GetxController {
  final results = <ResultItem>[].obs;
  final favourites = <String>{}.obs; // shade IDs
  final isLoading = true.obs;
  final isSharing = false.obs;

  // One ScreenshotController per result item, keyed by shade ID
  final screenshotControllers = <String, ScreenshotController>{};

  @override
  void onInit() {
    super.onInit();
    _loadFavourites();
    _buildResults();
  }

  void _loadFavourites() {
    favourites.addAll(FavouritesBox.getAll());
  }

  void _buildResults() {
    final toneCtrl = Get.find<SkinToneController>();
    final brandsCtrl = Get.find<BrandsController>();

    final tone = toneCtrl.selectedTone.value;
    final selectedShades = brandsCtrl.selectedShades;
    final allBrands = brandsCtrl.brands;

    if (tone == null) {
      isLoading.value = false;
      return;
    }

    final ideals = _idealShades[tone.id] ?? _idealShades['medium']!;
    final scored = <ResultItem>[];

    for (final brand in allBrands) {
      for (final shade in brand.shades) {
        if (!selectedShades.contains(shade.id)) continue;

        double total = 0;
        for (final ideal in ideals) {
          total += _closeness(shade.color, ideal);
        }
        scored.add(ResultItem(
          shade: shade,
          brand: brand,
          score: total / ideals.length,
        ));

        // Create a screenshot controller for each result
        screenshotControllers[shade.id] = ScreenshotController();
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    results.value = scored;
    isLoading.value = false;
  }

  // Toggle save/unsave a shade
  Future<void> toggleFavourite(String shadeId) async {
    if (favourites.contains(shadeId)) {
      favourites.remove(shadeId);
    } else {
      favourites.add(shadeId);
    }
    await FavouritesBox.save(favourites.toList());
  }

  bool isFavourite(String shadeId) => favourites.contains(shadeId);

  // Capture the share card and open native share sheet
  Future<void> shareResult(String shadeId) async {
    final ctrl = screenshotControllers[shadeId];
    if (ctrl == null) return;

    isSharing.value = true;
    try {
      final bytes = await ctrl.capture(pixelRatio: 3.0);
      if (bytes == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/findmyshade_$shadeId.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My lipstick pick from Find My Shade!',
      );
    } catch (_) {
      AppSnackbar.show(
        message: 'Could not share. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isSharing.value = false;
    }
  }

  double _closeness(Color a, Color b) {
    final dist = ((a.red - b.red) * (a.red - b.red) +
            (a.green - b.green) * (a.green - b.green) +
            (a.blue - b.blue) * (a.blue - b.blue))
        .toDouble();
    const maxDist = 195075.0;
    return 1.0 - (dist / maxDist);
  }
}
