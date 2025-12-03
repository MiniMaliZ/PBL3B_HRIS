import 'package:flutter/material.dart';

class HolidayFilterWidget extends StatefulWidget {
  final void Function(int month, int year) onFilterChanged;

  const HolidayFilterWidget({super.key, required this.onFilterChanged});

  @override
  State<HolidayFilterWidget> createState() => _HolidayFilterWidgetState();
}

class _HolidayFilterWidgetState extends State<HolidayFilterWidget> {
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFilterChanged(_selectedMonth!, _selectedYear!);
    });
  }

  List<DropdownMenuItem<int>> _yearItems() {
    final now = DateTime.now();
    final start = now.year - 5;
    final end = now.year + 5;
    return List.generate(end - start + 1, (i) => start + i)
        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedMonth,
            decoration: const InputDecoration(labelText: "Bulan"),
            items: [
              const DropdownMenuItem(value: 0, child: Text('Semua Bulan')),
              ...List.generate(
                12,
                (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i])),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedMonth = value);
              if (value != null && _selectedYear != null) {
                widget.onFilterChanged(value, _selectedYear!);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: const InputDecoration(labelText: "Tahun"),
            items: _yearItems(),
            onChanged: (value) {
              setState(() => _selectedYear = value);
              if (value != null && _selectedMonth != null) {
                widget.onFilterChanged(_selectedMonth!, value);
              }
            },
          ),
        ),
      ],
    );
  }
}
