import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';

class DataService {
  static const int _minLatency = 700;
  static const int _maxLatency = 1200;
  static const double _failureRate = 0.1;

  Future<List<BiometricData>> loadBiometricData({bool simulateLargeDataset = false}) async {
    await _simulateLatencyAndFailure();
    
    final jsonString = await rootBundle.loadString('assets/biometrics_90d.json');
    final jsonData = jsonDecode(jsonString) as List;
    
    var data = jsonData
        .map((item) => BiometricData.fromJson(item as Map<String, dynamic>))
        .toList();

    if (simulateLargeDataset) {
      data = _generateLargeDataset(data);
    }

    return data;
  }

  Future<List<JournalEntry>> loadJournalData() async {
    await _simulateLatencyAndFailure();
    
    final jsonString = await rootBundle.loadString('assets/journals.json');
    final jsonData = jsonDecode(jsonString) as List;
    
    return jsonData
        .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _simulateLatencyAndFailure() async {
    final random = Random();
    
    // Simulate latency
    final latency = _minLatency + random.nextInt(_maxLatency - _minLatency);
    await Future.delayed(Duration(milliseconds: latency));
    
    // Simulate ~10% failure rate
    if (random.nextDouble() < _failureRate) {
      throw Exception('Failed to load data. Please retry.');
    }
  }

  List<BiometricData> _generateLargeDataset(List<BiometricData> baseData) {
    final random = Random();
    final expanded = <BiometricData>[];
    
    for (var i = 0; i < 150; i++) {
      for (final data in baseData) {
        final variance = random.nextDouble() * 10 - 5;
        expanded.add(BiometricData(
          date: '${data.date}_$i',
          hrv: (data.hrv + variance).clamp(30, 100),
          rhr: (data.rhr + random.nextInt(5) - 2).clamp(50, 100),
          steps: (data.steps + random.nextInt(2000) - 1000).clamp(0, 15000),
          sleepScore: (data.sleepScore + random.nextInt(10) - 5).clamp(0, 100),
        ));
      }
    }
    
    return expanded;
  }
}
