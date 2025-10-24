import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_annotation_modal.dart';
import 'hrv_chart.dart';
import 'rhr_chart.dart';
import 'steps_chart.dart';

class ChartSection extends StatefulWidget {
  final List<BiometricData> data;
  final List<JournalEntry> journalData;
  final bool isMobile;
  final bool isTablet;

  const ChartSection({
    Key? key,
    required this.data,
    required this.journalData,
    this.isMobile = false,
    this.isTablet = false,
  }) : super(key: key);

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  double? _selectedX;

  void _showJournalEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => JournalAnnotationModal(
        entry: widget.journalData[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartHeight = widget.isMobile ? 250.0 : widget.isTablet ? 300.0 : 350.0;
    final spacing = widget.isMobile ? 16.0 : 24.0;

    return Column(
      children: [
        HRVChart(
          data: widget.data,
          journalData: widget.journalData,
          selectedX: _selectedX,
          onXChanged: (x) => setState(() => _selectedX = x),
          onJournalTap: _showJournalEntry,
          chartHeight: chartHeight,
        ),
        SizedBox(height: spacing),
        RHRChart(
          data: widget.data,
          selectedX: _selectedX,
          onXChanged: (x) => setState(() => _selectedX = x),
          chartHeight: chartHeight,
        ),
        SizedBox(height: spacing),
        StepsChart(
          data: widget.data,
          selectedX: _selectedX,
          onXChanged: (x) => setState(() => _selectedX = x),
          chartHeight: chartHeight,
        ),
      ],
    );
  }
}
