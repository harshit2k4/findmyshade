import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brand_model.dart';
import '../../data/models/skin_tone_model.dart';
import '../brands/brands_controller.dart';
import '../skin_tone/skin_tone_controller.dart';

class ResultItem {
  final ShadeModel shade;
  final BrandModel brand;
  final double score; // 0.0 to 1.0, higher is better

  const ResultItem({
    required this.shade,
    required this.brand,
    required this.score,
  });
}

// Ideal lip shade hex values per skin tone — based on makeup artist guidelines
// for Indian skin tones
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
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _buildResults();
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

        // Score = average closeness to all ideal colors (0 = far, 1 = perfect)
        double totalScore = 0;
        for (final ideal in ideals) {
          totalScore += _closeness(shade.color, ideal);
        }
        final avgScore = totalScore / ideals.length;

        scored.add(ResultItem(shade: shade, brand: brand, score: avgScore));
      }
    }

    // Sort best first
    scored.sort((a, b) => b.score.compareTo(a.score));
    results.value = scored;
    isLoading.value = false;
  }

  // Returns 0.0 (far) to 1.0 (identical)
  double _closeness(Color a, Color b) {
    final dist =
        ((a.red - b.red) * (a.red - b.red) +
                (a.green - b.green) * (a.green - b.green) +
                (a.blue - b.blue) * (a.blue - b.blue))
            .toDouble();
    const maxDist = 195075.0; // 255^2 * 3
    return 1.0 - (dist / maxDist);
  }
}
