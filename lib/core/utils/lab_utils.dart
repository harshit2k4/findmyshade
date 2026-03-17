import 'dart:math';

enum Undertone { warm, cool, neutral }

class LabUtils {
  LabUtils._();

  // RGB → LAB
  // LAB is perceptually uniform so distances here match human color perception
  // far better than RGB, making it ideal for skin tone matching.
  //
  // Pipeline: RGB → Linear RGB → XYZ (D65) → LAB
  static (double l, double a, double b) rgbToLab(int r, int g, int bVal) {
    // Normalize to 0-1 and linearize (remove gamma)
    double lin(int c) {
      final v = c / 255.0;
      return v <= 0.04045
          ? v / 12.92
          : pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    final lr = lin(r), lg = lin(g), lb = lin(bVal);

    // Linear RGB → XYZ (D65 illuminant)
    final x = lr * 0.4124 + lg * 0.3576 + lb * 0.1805;
    final y = lr * 0.2126 + lg * 0.7152 + lb * 0.0722;
    final z = lr * 0.0193 + lg * 0.1192 + lb * 0.9505;

    // XYZ → LAB
    double f(double t) =>
        t > 0.008856 ? pow(t, 1 / 3.0).toDouble() : (7.787 * t) + (16 / 116.0);

    final fx = f(x / 0.9505);
    final fy = f(y / 1.0000);
    final fz = f(z / 1.0890);

    final l = (116 * fy) - 16;
    final a = 500 * (fx - fy);
    final bLab = 200 * (fy - fz);

    return (l, a, bLab);
  }

  // LAB color distance (Delta E)
  // Lower = more perceptually similar
  static double labDistance(
    double l1,
    double a1,
    double b1,
    double l2,
    double a2,
    double b2,
  ) {
    final dl = l1 - l2, da = a1 - a2, db = b1 - b2;
    return sqrt(dl * dl + da * da + db * db);
  }

  // Undertone detection from dominant skin color
  // Uses the b* axis of LAB:
  //   b* high (>18)  = warm  (yellow/orange cast — turmeric, sun-kissed)
  //   b* low  (<10)  = cool  (pink/blue cast — rosy, ashish)
  //   b* mid         = neutral
  //
  // This is more reliable than HSL hue for Indian skin tones specifically.
  static Undertone detectUndertone(int r, int g, int bVal) {
    final (_, _, bLab) = rgbToLab(r, g, bVal);

    if (bLab > 18) return Undertone.warm;
    if (bLab < 10) return Undertone.cool;
    return Undertone.neutral;
  }

  // Undertone label
  static String undertoneLabel(Undertone u) {
    switch (u) {
      case Undertone.warm:
        return 'Warm';
      case Undertone.cool:
        return 'Cool';
      case Undertone.neutral:
        return 'Neutral';
    }
  }
}
