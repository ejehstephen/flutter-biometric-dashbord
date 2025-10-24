import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';

class HRVChart extends StatefulWidget {
  final List<BiometricData> data;
  final List<JournalEntry> journalData;
  final double? selectedX;
  final Function(double?) onXChanged;
  final Function(int)? onJournalTap;
  final double chartHeight;

  const HRVChart({
    Key? key,
    required this.data,
    required this.journalData,
    this.selectedX,
    required this.onXChanged,
    this.onJournalTap,
    this.chartHeight = 300,
  }) : super(key: key);

  @override
  State<HRVChart> createState() => _HRVChartState();
}

class _HRVChartState extends State<HRVChart> {
  late double _minX;
  late double _maxX;

  @override
  void initState() {
    super.initState();
    _minX = 0;
    _maxX = (widget.data.length - 1).toDouble();
  }

  @override
  void didUpdateWidget(HRVChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      _minX = 0;
      _maxX = (widget.data.length - 1).toDouble();
    }
  }

  List<LineChartBarData> _getLineChartBarData() {
    return [
      LineChartBarData(
        spots: widget.data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.hrv))
            .toList(),
        isCurved: true,
        color: Colors.blue,
        barWidth: 2,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  List<VerticalLine> _getVerticalLines() {
    final lines = <VerticalLine>[];
    for (int j = 0; j < widget.journalData.length; j++) {
      final journal = widget.journalData[j];
      final journalDate = DateTime.parse(journal.date);
      for (int i = 0; i < widget.data.length; i++) {
        final dataDate = DateTime.parse(widget.data[i].date);
        if (dataDate.year == journalDate.year &&
            dataDate.month == journalDate.month &&
            dataDate.day == journalDate.day) {
          lines.add(
            VerticalLine(
              x: i.toDouble(),
              color: Colors.orange.withOpacity(0.5),
              strokeWidth: 2,
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 8),
                labelResolver: (line) => 'Mood: ${journal.mood}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
          break;
        }
      }
    }
    return lines;
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
              'Heart Rate Variability (HRV)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to sync across charts • Swipe to pan • Pinch to zoom',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: widget.chartHeight,
              child: LineChart(
                LineChartData(
                  minX: _minX,
                  maxX: _maxX,
                  gridData: const FlGridData(show: true),
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
                  lineBarsData: _getLineChartBarData(),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      ..._getVerticalLines(),
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
                              const FlLine(color: Colors.blue, strokeWidth: 2),
                              FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.blue,
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
                              'HRV: ${data.hrv.toStringAsFixed(1)}\n${data.date}',
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
