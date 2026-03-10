import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../core/constants/app_routes.dart';
import '../../data/models/skin_tone_model.dart';

class SkinToneController extends GetxController {
  final selectedTone = Rxn<SkinToneModel>();
  final pickedImage = Rxn<File>();
  final isDetecting = false.obs;

  final _picker = ImagePicker();

  void selectTone(SkinToneModel tone) => selectedTone.value = tone;

  Future<void> pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xfile == null) return;

    pickedImage.value = File(xfile.path);
    isDetecting.value = true;

    try {
      final bytes = await pickedImage.value!.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;
      final detected = _detectTone(decoded);
      if (detected != null) selectedTone.value = detected;
    } finally {
      isDetecting.value = false;
    }
  }

  // Sample center patch and match to closest tone by color distance
  SkinToneModel? _detectTone(img.Image image) {
    final cx = image.width ~/ 2;
    final cy = image.height ~/ 2;
    const patch = 10;

    int rSum = 0, gSum = 0, bSum = 0, count = 0;

    for (var y = cy - patch; y <= cy + patch; y++) {
      for (var x = cx - patch; x <= cx + patch; x++) {
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
        final p = image.getPixel(x, y);
        rSum += p.r.toInt();
        gSum += p.g.toInt();
        bSum += p.b.toInt();
        count++;
      }
    }

    if (count == 0) return null;

    final avgR = rSum ~/ count;
    final avgG = gSum ~/ count;
    final avgB = bSum ~/ count;

    SkinToneModel? closest;
    double minDist = double.infinity;

    for (final tone in indianSkinTones) {
      final d = _dist(
        avgR,
        avgG,
        avgB,
        tone.color.red,
        tone.color.green,
        tone.color.blue,
      );
      if (d < minDist) {
        minDist = d;
        closest = tone;
      }
    }
    return closest;
  }

  double _dist(int r1, int g1, int b1, int r2, int g2, int b2) =>
      ((r1 - r2) * (r1 - r2) + (g1 - g2) * (g1 - g2) + (b1 - b2) * (b1 - b2))
          .toDouble();

  void proceed() {
    if (selectedTone.value == null) {
      Get.snackbar(
        'Select a tone',
        'Pick your skin tone to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppRoutes.brands);
  }
}
