import 'package:flutter_test/flutter_test.dart';
import 'package:biometrics_dashboard/providers/biometric_provider.dart';

void main() {
  group('BiometricProvider', () {
    test('Range switching updates filtered data correctly', () async {
      final provider = BiometricProvider();

      // Load data first
      await provider.loadData();

      provider.setDateRange(DateRange.ninetyDays);
      final ninetyDayCount = provider.filteredData.length;

      provider.setDateRange(DateRange.thirtyDays);
      final thirtyDayCount = provider.filteredData.length;

      provider.setDateRange(DateRange.sevenDays);
      final sevenDayCount = provider.filteredData.length;

      expect(sevenDayCount, lessThanOrEqualTo(thirtyDayCount));
      expect(thirtyDayCount, lessThanOrEqualTo(ninetyDayCount));
    });

    test('Large dataset toggle works correctly', () {
      final provider = BiometricProvider();

      expect(provider.useLargeDataset, false);

      provider.toggleLargeDataset();
      expect(provider.useLargeDataset, true);

      provider.toggleLargeDataset();
      expect(provider.useLargeDataset, false);
    });

    test('Loading state changes correctly', () async {
      final provider = BiometricProvider();

      expect(provider.isLoading, false);

      final loadFuture = provider.loadData();
      expect(provider.isLoading, true);

      await loadFuture;
      expect(provider.isLoading, false);
    });
  });
}
