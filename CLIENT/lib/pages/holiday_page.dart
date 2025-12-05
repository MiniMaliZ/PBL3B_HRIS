import 'package:flutter/material.dart';
import 'package:pbl3b_hris/widgets/holiday_filter_widget.dart';
import '../services/holiday_service.dart';
import '../pages/holiday_add_page.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({super.key});

  @override
  _HolidayPageState createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  final service = HolidayService();
  List holidays = [];
  bool loading = true;
  final Set<dynamic> selectedIds = {}; // selected holiday ids
  String apiBase = '';
  String lastMessage = '';

  @override
  void initState() {
    super.initState();
    loadAll();
    // Sinkronisasi otomatis data libur nasional
    syncNationalHolidays();
  }

  Future<void> loadAll() async {
    setState(() => loading = true);
    try {
      // resolve and show which API base URL is used
      apiBase = await service.getResolvedBaseUrl();
      print('Using API base in UI: $apiBase');
      final data = await service.getNationalHolidays();
      holidays = data;

      if (mounted && data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Tidak ada data hari libur. Coba sinkronisasi atau cek koneksi.'),
          action: SnackBarAction(label: 'Retry', onPressed: loadAll),
        ));
      }
    } catch (e) {
      lastMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error mengambil data: $e'),
        action: SnackBarAction(label: 'Retry', onPressed: loadAll),
      ));
      holidays = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> filterByMonth(int month) async {
    setState(() => loading = true);
    holidays = await service.getHolidayByMonth(month);
    setState(() => loading = false);
  }

  Future<void> filterByMonthYear(int month, int year) async {
    setState(() => loading = true);
    holidays = await service.getHolidayByMonthYear(month, year);
    setState(() => loading = false);
  }

  bool get isSelectionMode => selectedIds.isNotEmpty;

  void toggleSelection(dynamic id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Anda yakin ingin menghapus ${selectedIds.length} hari libur yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);
    int success = 0;

    // Copy selected ids to avoid modification during iteration
    final idsToDelete = selectedIds.toList();

    for (final id in idsToDelete) {
      final ok = await service.deleteHoliday(id);
      if (ok) success++;
    }

    // Remove deleted items from local list
    holidays.removeWhere((h) => idsToDelete.contains(h['id']));
    selectedIds.clear();
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Berhasil menghapus $success item'),
    ));
  }

  void goToAddHoliday() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHolidayPage()),
    );

    if (refresh == true) {
      loadAll();
    }
  }

  void syncNationalHolidays() async {
    final wasLoading = loading;
    setState(() => loading = true);

    final result = await service.syncNationalHolidays();

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      loadAll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => loading = wasLoading);
    }
  }

  void _showEditApiDialog() async {
    final controller = TextEditingController(text: apiBase);

    final save = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit API Base URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan base URL API (contoh: http://10.0.2.2:8000/api)'),
            const SizedBox(height: 8),
            TextField(controller: controller, decoration: const InputDecoration()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan')),
          TextButton(
              onPressed: () {
                // Reset to probe (clear override)
                service.setResolvedBaseUrl(null);
                Navigator.pop(c, true);
              },
              child: const Text('Reset')),
        ],
      ),
    );

    if (save == true) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        service.setResolvedBaseUrl(text);
      } else {
        service.setResolvedBaseUrl(null);
      }
      // reload with new base
      apiBase = await service.getResolvedBaseUrl();
      setState(() {
        loading = true;
      });
      await loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hari Libur"),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: selectedIds.length == holidays.length
                  ? const Icon(Icons.check_box)
                  : const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (selectedIds.length == holidays.length) {
                    selectedIds.clear();
                  } else {
                    selectedIds.clear();
                    for (final h in holidays) {
                      final id = h['id'];
                      if (id != null) selectedIds.add(id);
                    }
                  }
                });
              },
              tooltip: selectedIds.length == holidays.length ? 'Bersihkan pilihan' : 'Pilih Semua',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: deleteSelected,
              tooltip: 'Hapus yang dipilih',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: syncNationalHolidays,
            tooltip: "Sinkronisasi Libur Nasional",
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: goToAddHoliday,
            tooltip: "Tambah Hari Libur",
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: HolidayFilterWidget(onFilterChanged: filterByMonthYear),
          ),

          // Reset filter / show all button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // Clear selection and reload full list
                  setState(() {
                    selectedIds.clear();
                    loading = true;
                  });
                  loadAll();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tampilkan Semua'),
              ),
            ),
          ),

          if (lastMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Last: $lastMessage', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ),
            ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : holidays.isEmpty
                    ? const Center(
                        child: Text("Tidak ada data hari libur"),
                      )
                    : ListView.builder(
                        itemCount: holidays.length,
                        itemBuilder: (context, index) {
                          final h = holidays[index];
                          final id = h['id'];
                          final name = h['name'] ?? h['keterangan'] ?? 'N/A';
                          final date = h['date'] ?? h['tanggal'] ?? 'N/A';
                          final selected = selectedIds.contains(id);

                          return Card(
                            margin: const EdgeInsets.all(12),
                            child: ListTile(
                              onLongPress: () => toggleSelection(id),
                              onTap: () {
                                if (isSelectionMode) {
                                  toggleSelection(id);
                                }
                              },
                              title: Text(name),
                              subtitle: Text("Tanggal: $date"),
                              leading: isSelectionMode
                                  ? Checkbox(
                                      value: selected,
                                      onChanged: (_) => toggleSelection(id),
                                    )
                                  : const Icon(
                                      Icons.calendar_month,
                                      color: Colors.red,
                                    ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
