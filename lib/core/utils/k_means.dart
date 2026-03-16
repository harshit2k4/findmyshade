import 'dart:math';

class KMeans {
  KMeans._();

  // Finds k dominant colors from a list of RGB pixels.
  // Returns cluster centers sorted by size (largest first).
  // We use this to find the true dominant skin color from the sampled region,
  // ignoring noise pixels (hair, shadows, specular highlights).
  static List<(int r, int g, int b)> cluster(
    List<(int, int, int)> pixels, {
    int k = 3,
    int iterations = 15,
  }) {
    if (pixels.isEmpty) return [];
    if (pixels.length <= k) return pixels;

    final rng = Random(42); // fixed seed for reproducibility

    // Initialize centers by picking k random pixels (k-means++)
    final centers = <(double, double, double)>[];
    centers.add(_toDouble(pixels[rng.nextInt(pixels.length)]));

    while (centers.length < k) {
      // Pick next center weighted by distance from existing centers
      final dists = pixels.map((p) {
        final pd = _toDouble(p);
        return centers.map((c) => _dist(pd, c)).reduce(min);
      }).toList();

      final total = dists.fold(0.0, (a, b) => a + b);
      var target = rng.nextDouble() * total;

      for (var i = 0; i < pixels.length; i++) {
        target -= dists[i];
        if (target <= 0) {
          centers.add(_toDouble(pixels[i]));
          break;
        }
      }
      if (centers.length < k) centers.add(_toDouble(pixels.last));
    }

    final assignments = List<int>.filled(pixels.length, 0);

    for (var iter = 0; iter < iterations; iter++) {
      // Assign each pixel to nearest center
      for (var i = 0; i < pixels.length; i++) {
        final pd = _toDouble(pixels[i]);
        double minD = double.infinity;
        int best = 0;
        for (var j = 0; j < k; j++) {
          final d = _dist(pd, centers[j]);
          if (d < minD) {
            minD = d;
            best = j;
          }
        }
        assignments[i] = best;
      }

      // Recompute centers as mean of assigned pixels
      final sums = List.filled(k, (0.0, 0.0, 0.0));
      final counts = List<int>.filled(k, 0);

      for (var i = 0; i < pixels.length; i++) {
        final j = assignments[i];
        final pd = _toDouble(pixels[i]);
        sums[j] = (sums[j].$1 + pd.$1, sums[j].$2 + pd.$2, sums[j].$3 + pd.$3);
        counts[j]++;
      }

      for (var j = 0; j < k; j++) {
        if (counts[j] == 0) continue;
        centers[j] = (
          sums[j].$1 / counts[j],
          sums[j].$2 / counts[j],
          sums[j].$3 / counts[j],
        );
      }
    }

    // Count cluster sizes and sort by largest first
    final sizes = List<int>.filled(k, 0);
    for (final a in assignments) sizes[a]++;

    final indexed = List.generate(k, (j) => (j, sizes[j]));
    indexed.sort((a, b) => b.$2.compareTo(a.$2));

    return indexed
        .map((e) => (
              centers[e.$1].$1.round().clamp(0, 255),
              centers[e.$1].$2.round().clamp(0, 255),
              centers[e.$1].$3.round().clamp(0, 255),
            ))
        .toList();
  }

  static (double, double, double) _toDouble((int, int, int) p) =>
      (p.$1.toDouble(), p.$2.toDouble(), p.$3.toDouble());

  static double _dist((double, double, double) a, (double, double, double) b) {
    final dr = a.$1 - b.$1, dg = a.$2 - b.$2, db = a.$3 - b.$3;
    return dr * dr + dg * dg + db * db;
  }
}
