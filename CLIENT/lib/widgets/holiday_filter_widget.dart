import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // <-- Tambahkan import

class HolidayFilterWidget extends StatefulWidget {
  final Function(int month, int year) onFilterChanged;

  const HolidayFilterWidget({super.key, required this.onFilterChanged});

  @override
  State<HolidayFilterWidget> createState() => _HolidayFilterWidgetState();
}

class _HolidayFilterWidgetState extends State<HolidayFilterWidget> {
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Dropdown Bulan
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondaryLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryDark),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_monthNames[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMonth = value);
                      widget.onFilterChanged(_selectedMonth, _selectedYear);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Dropdown Tahun
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondaryLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryDark),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
                items: List.generate(10, (index) {
                  final year = DateTime.now().year - 5 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$year'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedYear = value);
                    widget.onFilterChanged(_selectedMonth, _selectedYear);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}