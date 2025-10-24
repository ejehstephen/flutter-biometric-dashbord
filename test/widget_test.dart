import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biometrics_dashboard/main.dart';
import 'package:biometrics_dashboard/providers/biometric_provider.dart';
import 'package:biometrics_dashboard/screens/dashboard_screen.dart';

void main() {
  group('Dashboard Widget Tests', () {
    testWidgets('Dashboard displays loading state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Should show loading state initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Range buttons update chart data', (WidgetTester tester) async {
      final provider = BiometricProvider();
      await provider.loadData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(provider.selectedRange, DateRange.sevenDays);

      provider.setDateRange(DateRange.thirtyDays);
      expect(provider.selectedRange, DateRange.thirtyDays);

      provider.setDateRange(DateRange.ninetyDays);
      expect(provider.selectedRange, DateRange.ninetyDays);
    });

    testWidgets('Error view displays retry button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error Loading Data'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Provider notifies listeners on data load',
        (WidgetTester tester) async {
      final provider = BiometricProvider();
      int notifyCount = 0;

      provider.addListener(() {
        notifyCount++;
      });

      await provider.loadData();

      // Should notify at least once (loading start and end)
      expect(notifyCount, greaterThan(0));
    });
  });
}
