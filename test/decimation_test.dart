import 'package:flutter_test/flutter_test.dart';
import 'package:biometrics_dashboard/models/biometric_data.dart';
import 'package:biometrics_dashboard/services/decimation_service.dart';

void main() {
  group('DecimationService', () {
    test('LTTB decimation reduces data size correctly', () {
      final data = List.generate(
        100,
        (i) => BiometricData(
          date: '2025-08-${(i % 30) + 1}',
          hrv: 50 + (i % 20).toDouble(),
          rhr: 60,
          steps: 5000,
          sleepScore: 75,
        ),
      );

      final decimated = DecimationService.decimate(data, 20);

      expect(decimated.length, equals(20));
      expect(decimated.first, equals(data.first));
      expect(decimated.last, equals(data.last));
    });

    test('LTTB decimation preserves min/max values', () {
      final data = List.generate(
        100,
        (i) => BiometricData(
          date: '2025-08-${(i % 30) + 1}',
          hrv: 50 + (i % 20).toDouble(),
          rhr: 60,
          steps: 5000,
          sleepScore: 75,
        ),
      );

      final decimated = DecimationService.decimate(data, 20);

      final originalMin = data.map((d) => d.hrv).reduce((a, b) => a < b ? a : b);
      final originalMax = data.map((d) => d.hrv).reduce((a, b) => a > b ? a : b);

      final decimatedMin = decimated.map((d) => d.hrv).reduce((a, b) => a < b ? a : b);
      final decimatedMax = decimated.map((d) => d.hrv).reduce((a, b) => a > b ? a : b);

      expect(decimatedMin, lessThanOrEqualTo(originalMin + 1));
      expect(decimatedMax, greaterThanOrEqualTo(originalMax - 1));
    });

    test('Bucket aggregation reduces data size correctly', () {
      final data = List.generate(
        100,
        (i) => BiometricData(
          date: '2025-08-${(i % 30) + 1}',
          hrv: 50 + (i % 20).toDouble(),
          rhr: 60,
          steps: 5000,
          sleepScore: 75,
        ),
      );

      final aggregated = DecimationService.aggregateByBuckets(data, 10);

      expect(aggregated.length, equals(10));
    });

    test('Decimation handles small datasets gracefully', () {
      final data = List.generate(
        5,
        (i) => BiometricData(
          date: '2025-08-${i + 1}',
          hrv: 50 + i.toDouble(),
          rhr: 60,
          steps: 5000,
          sleepScore: 75,
        ),
      );

      final decimated = DecimationService.decimate(data, 10);

      expect(decimated.length, equals(5));
      expect(decimated, equals(data));
    });

    test('Aggregation handles empty data', () {
      final data = <BiometricData>[];
      final aggregated = DecimationService.aggregateByBuckets(data, 10);

      expect(aggregated.isEmpty, true);
    });
  });
}
