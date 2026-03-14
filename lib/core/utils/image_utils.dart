import 'package:image/image.dart' as img;

// Result of the lighting check
enum LightingStatus { good, tooDark, tooBright }

class ImageUtils {
  ImageUtils._();

  // Lighting check
  // Samples average brightness (0-255) from the image.
  // Too dark  < 40  : underexposed, colors will be inaccurate
  // Too bright > 220 : overexposed, colors washed out
  static LightingStatus checkLighting(img.Image image) {
    final cx = image.width ~/ 2;
    final cy = image.height ~/ 2;
    const patch = 30;

    int total = 0, count = 0;

    for (var y = cy - patch; y <= cy + patch; y++) {
      for (var x = cx - patch; x <= cx + patch; x++) {
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
        final p = image.getPixel(x, y);
        // Perceived brightness using standard luminance weights
        final brightness = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
        total += brightness;
        count++;
      }
    }

    if (count == 0) return LightingStatus.good;
    final avg = total / count;

    if (avg < 40) return LightingStatus.tooDark;
    if (avg > 220) return LightingStatus.tooBright;
    return LightingStatus.good;
  }

  // White balance normalization
  // Finds the brightest patch in the image (assumed to be near-white under
  // the scene's light source) and uses it to cancel the light tint.
  // Returns a new normalized image.
  static img.Image normalizeWhiteBalance(img.Image src) {
    // Find max R, G, B across a sample of pixels
    double maxR = 1, maxG = 1, maxB = 1;

    final stepX = (src.width / 20).ceil();
    final stepY = (src.height / 20).ceil();

    for (var y = 0; y < src.height; y += stepY) {
      for (var x = 0; x < src.width; x += stepX) {
        final p = src.getPixel(x, y);
        if (p.r > maxR) maxR = p.r.toDouble();
        if (p.g > maxG) maxG = p.g.toDouble();
        if (p.b > maxB) maxB = p.b.toDouble();
      }
    }

    // Scale each channel so its max maps to 255
    final scaleR = 255.0 / maxR;
    final scaleG = 255.0 / maxG;
    final scaleB = 255.0 / maxB;

    final out = img.Image(width: src.width, height: src.height);

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        out.setPixelRgb(
          x,
          y,
          (p.r * scaleR).clamp(0, 255).round(),
          (p.g * scaleG).clamp(0, 255).round(),
          (p.b * scaleB).clamp(0, 255).round(),
        );
      }
    }

    return out;
  }

  // Center patch average (Classic algorithm)
  // Samples a patch around the image center and returns average RGB.
  static (int r, int g, int b) sampleCenterPatch(img.Image image,
      {int patch = 20}) {
    final cx = image.width ~/ 2;
    final cy = image.height ~/ 2;

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

    if (count == 0) return (128, 80, 60);
    return (rSum ~/ count, gSum ~/ count, bSum ~/ count);
  }
}
