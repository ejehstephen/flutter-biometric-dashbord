import 'package:flutter/material.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';
import '../services/data_service.dart';
import '../services/decimation_service.dart';

enum DateRange { sevenDays, thirtyDays, ninetyDays }

class BiometricProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<BiometricData> _allData = [];
  List<BiometricData> _filteredData = [];
  List<JournalEntry> _journalData = [];
  DateRange _selectedRange = DateRange.sevenDays;
  bool _isLoading = false;
  String? _error;
  bool _useLargeDataset = false;

  // Getters
  List<BiometricData> get filteredData => _filteredData;
  List<JournalEntry> get journalData => _journalData;
  DateRange get selectedRange => _selectedRange;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useLargeDataset => _useLargeDataset;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allData = await _dataService.loadBiometricData(simulateLargeDataset: _useLargeDataset);
      _journalData = await _dataService.loadJournalData();
      _applyRangeFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateRange range) {
    _selectedRange = range;
    _applyRangeFilter();
    notifyListeners();
  }

  void toggleLargeDataset() {
    _useLargeDataset = !_useLargeDataset;
    notifyListeners();
  }

  void _applyRangeFilter() {
    if (_allData.isEmpty) {
      _filteredData = [];
      return;
    }

    final now = DateTime.parse(_allData.last.date);
    final daysBack = _selectedRange == DateRange.sevenDays
        ? 7
        : _selectedRange == DateRange.thirtyDays
            ? 30
            : 90;

    final cutoffDate = now.subtract(Duration(days: daysBack));

    _filteredData = _allData
        .where((data) => DateTime.parse(data.date).isAfter(cutoffDate))
        .toList();

    // Apply decimation for larger ranges
    if (_selectedRange == DateRange.thirtyDays && _filteredData.length > 100) {
      _filteredData = DecimationService.decimate(_filteredData, 100);
    } else if (_selectedRange == DateRange.ninetyDays && _filteredData.length > 150) {
      _filteredData = DecimationService.decimate(_filteredData, 150);
    }
  }

  Future<void> retry() async {
    await loadData();
  }
}
