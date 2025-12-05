import 'package:flutter/material.dart';
import '../services/holiday_service.dart';

class AddHolidayPage extends StatefulWidget {
  const AddHolidayPage({super.key});

  @override
  _AddHolidayPageState createState() => _AddHolidayPageState();
}

class _AddHolidayPageState extends State<AddHolidayPage> {
  final _formKey = GlobalKey<FormState>();
  final service = HolidayService();

  TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;

  void saveHoliday() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal terlebih dahulu")),
      );
      return;
    }

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan nama hari libur")),
      );
      return;
    }

    // Format: YYYY-MM-DD
    final date =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final ok = await service.addHoliday(date, nameController.text);

    if (!mounted) return;

    if (ok) {
      // Show a short confirmation popup then return to the previous page
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const AlertDialog(
          title: Text('Sukses'),
          content: Text('Data tersimpan'),
        ),
      );

      // wait briefly so user sees the popup
      await Future.delayed(const Duration(milliseconds: 900));

      // close the dialog and pop this page returning true
      if (mounted) {
        Navigator.of(context).pop(); // close dialog
        Navigator.of(context).pop(true); // return to holiday page
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menambahkan libur")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Hari Libur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Hari Libur"),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDate: DateTime.now(),
                  );

                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: Text(
                  selectedDate == null
                      ? "Pilih Tanggal"
                      : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: saveHoliday,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
