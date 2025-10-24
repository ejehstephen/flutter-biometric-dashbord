import '../models/biometric_data.dart';

class DecimationService {
  /// Largest-Triangle-Three-Buckets (LTTB) algorithm for downsampling
  static List<BiometricData> decimate(
    List<BiometricData> data,
    int targetPoints,
  ) {
    if (data.length <= targetPoints) return data;

    final bucketSize = (data.length - 2) / (targetPoints - 2);
    final decimated = <BiometricData>[data.first];

    for (int i = 0; i < targetPoints - 2; i++) {
      final avgRangeStart = ((i + 1) * bucketSize).floor() + 1;
      final avgRangeEnd = ((i + 2) * bucketSize).floor() + 1;
      final avgRangeLength = avgRangeEnd - avgRangeStart;

      double avgX = 0;
      double avgY = 0;

      for (int j = avgRangeStart; j < avgRangeEnd && j < data.length; j++) {
        avgX += j;
        avgY += data[j].hrv;
      }

      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      final rangeStart = (i * bucketSize).floor() + 1;
      final rangeEnd = ((i + 1) * bucketSize).floor() + 1;

      double maxArea = -1;
      int maxAreaIndex = -1;

      for (int j = rangeStart; j < rangeEnd && j < data.length; j++) {
        final area = _triangleArea(
          (decimated.length - 1).toDouble(),
          j.toDouble(),
          avgX,
          decimated.last.hrv,
          data[j].hrv,
          avgY,
        );

        if (area > maxArea) {
          maxArea = area;
          maxAreaIndex = j;
        }
      }

      if (maxAreaIndex != -1) {
        decimated.add(data[maxAreaIndex]);
      }
    }

    decimated.add(data.last);
    return decimated;
  }

  /// Bucket mean aggregation for simple downsampling
  static List<BiometricData> aggregateByBuckets(
    List<BiometricData> data,
    int bucketCount,
  ) {
    if (data.isEmpty) return [];
    if (data.length <= bucketCount) return data;

    final bucketSize = data.length / bucketCount;
    final aggregated = <BiometricData>[];

    for (int i = 0; i < bucketCount; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).floor();
      final bucket = data.sublist(start, end);

      if (bucket.isNotEmpty) {
        final avgHrv =
            bucket.map((d) => d.hrv).reduce((a, b) => a + b) / bucket.length;
        final avgRhr =
            (bucket.map((d) => d.rhr).reduce((a, b) => a + b) / bucket.length)
                .round();
        final avgSteps =
            (bucket.map((d) => d.steps).reduce((a, b) => a + b) / bucket.length)
                .round();
        final avgSleep =
            (bucket.map((d) => d.sleepScore).reduce((a, b) => a + b) /
                    bucket.length)
                .round();

        aggregated.add(BiometricData(
          date: bucket.first.date,
          hrv: avgHrv,
          rhr: avgRhr,
          steps: avgSteps,
          sleepScore: avgSleep,
        ));
      }
    }

    return aggregated;
  }

  static double _triangleArea(
      double x1, double x2, double x3, double y1, double y2, double y3) {
    return ((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)).abs()) / 2;
  }
}
