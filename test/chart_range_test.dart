import 'package:flutter_test/flutter_test.dart';
import 'package:biometrics_dashboard/providers/biometric_provider.dart';

void main() {
  group('BiometricProvider Range Switching', () {
    test('Switching from 90d to 7d updates filtered data', () async {
      final provider = BiometricProvider();

      // Load data first
      await provider.loadData();

      provider.setDateRange(DateRange.ninetyDays);
      final ninetyDayCount = provider.filteredData.length;

      provider.setDateRange(DateRange.sevenDays);
      final sevenDayCount = provider.filteredData.length;

      expect(sevenDayCount, lessThanOrEqualTo(ninetyDayCount));
    });

    test('Selected range persists correctly', () async {
      final provider = BiometricProvider();

      await provider.loadData();

      expect(provider.selectedRange, DateRange.sevenDays);

      provider.setDateRange(DateRange.thirtyDays);
      expect(provider.selectedRange, DateRange.thirtyDays);

      provider.setDateRange(DateRange.ninetyDays);
      expect(provider.selectedRange, DateRange.ninetyDays);
    });
  });
}
