import 'dart:io';
import 'package:findmyshade/core/utils/k_means.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'lab_utils.dart';
import '../../data/models/skin_tone_model.dart';

class DetectionResult {
  final SkinToneModel tone;
  final Undertone undertone;
  final bool faceFound; // false = fell back to center-patch

  const DetectionResult({
    required this.tone,
    required this.undertone,
    required this.faceFound,
  });
}

class MLDetector {
  MLDetector._();

  static final _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Tries face detection first. If no face found (e.g. user cropped just
  // their wrist/arm), falls back to center-patch K-Means on the whole image.
  static Future<DetectionResult> detect(
      File imageFile, img.Image decoded) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final faces = await _detector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final pixels = _sampleCheekPixels(faces.first, decoded);
        if (pixels.isNotEmpty) {
          return _buildResult(pixels, faceFound: true);
        }
      }
    } catch (_) {
      // ML Kit failed — fall through to center-patch
    }

    // Fallback: sample entire cropped image with K-Means
    final pixels = _sampleAllPixels(decoded);
    return _buildResult(pixels, faceFound: false);
  }

  // Sample pixels from both cheek regions
  // ML Kit gives landmark positions, so we sample a 30x30 patch around
  // each cheek and combine them for a robust skin color sample.
  static List<(int, int, int)> _sampleCheekPixels(Face face, img.Image image) {
    final pixels = <(int, int, int)>[];

    for (final type in [
      FaceLandmarkType.leftCheek,
      FaceLandmarkType.rightCheek,
    ]) {
      final landmark = face.landmarks[type];
      if (landmark == null) continue;

      final cx = landmark.position.x.toInt();
      final cy = landmark.position.y.toInt();
      const patch = 15;

      for (var y = cy - patch; y <= cy + patch; y += 2) {
        for (var x = cx - patch; x <= cx + patch; x += 2) {
          if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
          final p = image.getPixel(x, y);
          // Skip pixels that look like hair/shadow (too dark) or highlights
          final brightness = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
          if (brightness < 40 || brightness > 220) continue;
          pixels.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
        }
      }
    }

    return pixels;
  }

  // Sample pixels from entire cropped image
  // Sparse grid sample, skipping highlights and shadows.
  static List<(int, int, int)> _sampleAllPixels(img.Image image) {
    final pixels = <(int, int, int)>[];
    final stepX = (image.width / 30).ceil();
    final stepY = (image.height / 30).ceil();

    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        final p = image.getPixel(x, y);
        final brightness = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        if (brightness < 40 || brightness > 220) continue;
        pixels.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
      }
    }

    return pixels;
  }

  // Build result from sampled pixels
  // Runs K-Means (k=3) to find dominant colors.
  // The largest cluster = true skin color.
  // Then matches to Indian tone in LAB space and detects undertone.
  static DetectionResult _buildResult(
    List<(int, int, int)> pixels, {
    required bool faceFound,
  }) {
    final clusters = KMeans.cluster(pixels, k: 3);
    final dominant = clusters.first; // largest cluster

    final tone = _matchToneLab(dominant.$1, dominant.$2, dominant.$3);
    final undertone =
        LabUtils.detectUndertone(dominant.$1, dominant.$2, dominant.$3);

    return DetectionResult(
      tone: tone ?? indianSkinTones[2], // default to wheatish
      undertone: undertone,
      faceFound: faceFound,
    );
  }

  // Match to Indian tone using LAB distance
  static SkinToneModel? _matchToneLab(int r, int g, int b) {
    final (l1, a1, b1) = LabUtils.rgbToLab(r, g, b);

    SkinToneModel? closest;
    double minDist = double.infinity;

    for (final tone in indianSkinTones) {
      final (l2, a2, b2) =
          LabUtils.rgbToLab(tone.color.red, tone.color.green, tone.color.blue);
      final d = LabUtils.labDistance(l1, a1, b1, l2, a2, b2);
      if (d < minDist) {
        minDist = d;
        closest = tone;
      }
    }

    return closest;
  }

  static void close() => _detector.close();
}
