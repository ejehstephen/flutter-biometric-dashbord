import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/biometric_data.dart';

class RHRChart extends StatefulWidget {
  final List<BiometricData> data;
  final double? selectedX;
  final Function(double?) onXChanged;
  final double chartHeight;

  const RHRChart({
    Key? key,
    required this.data,
    this.selectedX,
    required this.onXChanged,
    this.chartHeight = 300,
  }) : super(key: key);

  @override
  State<RHRChart> createState() => _RHRChartState();
}

class _RHRChartState extends State<RHRChart> {
  late double _minX;
  late double _maxX;

  @override
  void initState() {
    super.initState();
    _minX = 0;
    _maxX = (widget.data.length - 1).toDouble();
  }

  @override
  void didUpdateWidget(RHRChart oldWidget) {
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
              'Resting Heart Rate (RHR)',
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
              child: LineChart(
                LineChartData(
                  minX: _minX,
                  maxX: _maxX,
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
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.data
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.rhr.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      if (widget.selectedX != null)
                        VerticalLine(
                          x: widget.selectedX!,
                          color: Colors.orange,
                          strokeWidth: 2,
                        ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? response) {
                      if (event is FlTapUpEvent) {
                        if (response?.lineBarSpots?.isNotEmpty ?? false) {
                          widget.onXChanged(response!.lineBarSpots!.first.x);
                        } else {
                          widget.onXChanged(null);
                        }
                      }
                    },
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes
                          .map(
                            (index) => TouchedSpotIndicatorData(
                              FlLine(color: Colors.red, strokeWidth: 2),
                              FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.red,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < widget.data.length) {
                            final data = widget.data[index];
                            return LineTooltipItem(
                              'RHR: ${data.rhr}\n${data.date}',
                              const TextStyle(color: Colors.white),
                            );
                          }
                          return null;
                        }).toList();
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
