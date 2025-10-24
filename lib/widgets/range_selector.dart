import 'package:flutter/material.dart';
import '../providers/biometric_provider.dart';

class RangeSelector extends StatelessWidget {
  final DateRange selectedRange;
  final Function(DateRange) onRangeChanged;
  final bool isMobile;

  const RangeSelector({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildButton(context, '7D', DateRange.sevenDays),
            const SizedBox(width: 8),
            _buildButton(context, '30D', DateRange.thirtyDays),
            const SizedBox(width: 8),
            _buildButton(context, '90D', DateRange.ninetyDays),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildButton(context, '7 Days', DateRange.sevenDays),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(context, '30 Days', DateRange.thirtyDays),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(context, '90 Days', DateRange.ninetyDays),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, DateRange range) {
    final isSelected = selectedRange == range;
    return ElevatedButton(
      onPressed: () => onRangeChanged(range),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 8 : 12,
          horizontal: isMobile ? 12 : 16,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 12 : 14),
      ),
    );
  }
}
