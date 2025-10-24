import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/biometric_provider.dart';
import '../widgets/chart_section.dart';
import '../widgets/range_selector.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/error_view.dart';
import '../widgets/stats_summary.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    final horizontalPadding = isMobile ? 12.0 : isTablet ? 16.0 : 24.0;
    final verticalSpacing = isMobile ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrics Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
            child: Center(
              child: Consumer<BiometricProvider>(
                builder: (context, provider, _) {
                  return Text(
                    isMobile
                        ? '${provider.filteredData.length} pts'
                        : '${provider.filteredData.length} data points',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<BiometricProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingSkeleton();
          }

          if (provider.error != null) {
            return ErrorView(
              error: provider.error!,
              onRetry: () => provider.retry(),
            );
          }

          if (provider.filteredData.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatsSummary(data: provider.filteredData, isMobile: isMobile),
                  SizedBox(height: verticalSpacing),
                  RangeSelector(
                    selectedRange: provider.selectedRange,
                    onRangeChanged: (range) => provider.setDateRange(range),
                    isMobile: isMobile,
                  ),
                  SizedBox(height: verticalSpacing),
                  ChartSection(
                    data: provider.filteredData,
                    journalData: provider.journalData,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: verticalSpacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: provider.useLargeDataset,
                            onChanged: (_) => provider.toggleLargeDataset(),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Simulate Large Dataset'),
                                Text(
                                  '10k+ points for performance testing',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
