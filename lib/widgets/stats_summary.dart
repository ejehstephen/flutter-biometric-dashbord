import 'package:flutter/material.dart';
import '../models/biometric_data.dart';

class StatsSummary extends StatelessWidget {
  final List<BiometricData> data;
  final bool isMobile;

  const StatsSummary({
    Key? key,
    required this.data,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final hrvValues = data.map((d) => d.hrv).toList();
    final rhrValues = data.map((d) => d.rhr).toList();
    final stepsValues = data.map((d) => d.steps).toList();

    final hrvAvg = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
    final rhrAvg = rhrValues.reduce((a, b) => a + b) / rhrValues.length;
    final stepsTotal = stepsValues.reduce((a, b) => a + b);

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatCard(
              title: 'Avg HRV',
              value: hrvAvg.toStringAsFixed(1),
              unit: 'ms',
              color: Colors.blue,
              width: 140,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Avg RHR',
              value: rhrAvg.toStringAsFixed(0),
              unit: 'bpm',
              color: Colors.red,
              width: 140,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Total Steps',
              value: (stepsTotal / 1000).toStringAsFixed(1),
              unit: 'k',
              color: Colors.green,
              width: 140,
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _StatCard(
          title: 'Avg HRV',
          value: hrvAvg.toStringAsFixed(1),
          unit: 'ms',
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Avg RHR',
          value: rhrAvg.toStringAsFixed(0),
          unit: 'bpm',
          color: Colors.red,
        ),
        _StatCard(
          title: 'Total Steps',
          value: (stepsTotal / 1000).toStringAsFixed(1),
          unit: 'k',
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final double? width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }
}
