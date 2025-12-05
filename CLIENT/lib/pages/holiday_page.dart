import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // <-- Tambahkan import
import '../widgets/app_drawer.dart';
import '../widgets/holiday_filter_widget.dart';
import '../services/holiday_service.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({super.key});

  @override
  State<HolidayPage> createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  final HolidayService _service = HolidayService();
  List<dynamic> holidays = [];
  List<dynamic> filteredHolidays = [];
  Set<int> selectedIds = {};
  bool isLoading = true;
  bool isSelectionMode = false;
  String? errorMessage;

  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await syncNationalHolidays();
    await loadAll();
  }

  Future<void> syncNationalHolidays() async {
    try {
      await _service.syncNationalHolidays(_currentYear);
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _service.fetchHolidays();
      setState(() {
        holidays = data;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilter() {
    filteredHolidays = holidays.where((h) {
      final date = DateTime.tryParse(h['date'] ?? h['tanggal'] ?? '');
      if (date == null) return false;
      return date.month == _currentMonth && date.year == _currentYear;
    }).toList();

    filteredHolidays.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? a['tanggal'] ?? '');
      final dateB = DateTime.tryParse(b['date'] ?? b['tanggal'] ?? '');
      return (dateA ?? DateTime.now()).compareTo(dateB ?? DateTime.now());
    });
  }

  void _onFilterChanged(int month, int year) {
    setState(() {
      _currentMonth = month;
      _currentYear = year;
      _applyFilter();
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        if (selectedIds.isEmpty) isSelectionMode = false;
      } else {
        selectedIds.add(id);
        isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus ${selectedIds.length} hari libur yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in selectedIds) {
        await _service.deleteHoliday(id);
      }
      setState(() {
        selectedIds.clear();
        isSelectionMode = false;
      });
      loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Hari Libur'),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteSelected,
            ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await syncNationalHolidays();
              await loadAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sinkronisasi selesai'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          HolidayFilterWidget(onFilterChanged: _onFilterChanged),

          // Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Hari Libur',
                        style: TextStyle(
                          color: AppColors.secondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${filteredHolidays.length} Hari',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryDark,
                    ),
                  )
                : errorMessage != null
                ? _buildErrorWidget()
                : filteredHolidays.isEmpty
                ? _buildEmptyWidget()
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/holiday/add');
          if (result == true) loadAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: loadAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: AppColors.secondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hari libur',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Bulan ini belum ada data hari libur',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredHolidays.length,
      itemBuilder: (context, index) {
        final holiday = filteredHolidays[index];
        final id = holiday['id'];
        final name = holiday['name'] ?? holiday['keterangan'] ?? '-';
        final dateStr = holiday['date'] ?? holiday['tanggal'] ?? '';
        final date = DateTime.tryParse(dateStr);
        final isSelected = selectedIds.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: AppColors.primaryDark, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(id),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date != null ? '${date.day}' : '-',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          date != null ? _getMonthShort(date.month) : '',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Text(
              date != null
                  ? '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}'
                  : dateStr,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            onTap: () => _toggleSelection(id),
            onLongPress: () {
              setState(() {
                isSelectionMode = true;
                selectedIds.add(id);
              });
            },
          ),
        );
      },
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }
}
