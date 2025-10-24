import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/biometric_data.dart';

class StepsChart extends StatefulWidget {
  final List<BiometricData> data;
  final double? selectedX;
  final Function(double?) onXChanged;
  final double chartHeight;

  const StepsChart({
    Key? key,
    required this.data,
    this.selectedX,
    required this.onXChanged,
    this.chartHeight = 300,
  }) : super(key: key);

  @override
  State<StepsChart> createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  late double _minX;
  late double _maxX;

  @override
  void initState() {
    super.initState();
    _minX = 0;
    _maxX = (widget.data.length - 1).toDouble();
  }

  @override
  void didUpdateWidget(StepsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      _minX = 0;
      _maxX = (widget.data.length - 1).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Steps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to sync across charts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: widget.chartHeight,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 10 == 0 &&
                              value.toInt() < widget.data.length) {
                            return Text(
                              widget.data[value.toInt()].date.substring(5),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toInt()}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: widget.data
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.steps.toDouble(),
                                color: Colors.green,
                              ),
                            ],
                          ))
                      .toList(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback:
                        (FlTouchEvent event, BarTouchResponse? response) {
                      if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                        if (response?.spot != null) {
                          widget.onXChanged(
                              response!.spot!.touchedBarGroup.x.toDouble());
                        }
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= 0 &&
                            groupIndex < widget.data.length) {
                          final data = widget.data[groupIndex];
                          return BarTooltipItem(
                            'Steps: ${data.steps}\n${data.date}',
                            const TextStyle(color: Colors.white),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.selectedX != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Selected: ${widget.data[widget.selectedX!.toInt()].date}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
