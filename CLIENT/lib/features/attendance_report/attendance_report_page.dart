import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  List<dynamic> attendanceData = [];
  String? selectedEmployeeName; // Nama 
  DateTime? selectedDate; // Tanggal filter
  bool isLoading = false;

  TextEditingController employeeController = TextEditingController();

  final String baseUrl = 'http://192.168.1.104:8000/api'; // ganti sesuai IP LAN LAPTOP Anda

  @override
  void initState() {
    super.initState();
    fetchAttendanceReport(); // tampil semua awalnya
  }

  // ================== FETCH ATTENDANCE ==================
  Future<void> fetchAttendanceReport() async {
    setState(() => isLoading = true);

    Map<String, String> queryParams = {};

    // Filter nama karyawan jika ada input
    if (selectedEmployeeName != null && selectedEmployeeName!.isNotEmpty) {
      queryParams['employee_name'] = selectedEmployeeName!;
    }

    // Filter tanggal jika dipilih
    if (selectedDate != null) {
      String dateStr =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      queryParams['start_date'] = dateStr;
      queryParams['end_date'] = dateStr;
    }

    final uri =
        Uri.parse('$baseUrl/attendance/report').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      print("FETCH URL: $uri");             // Debug URL
      print("RESPONSE: ${response.body}");  // Debug response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          attendanceData = data['data'] ?? [];
        });
      } else {
        throw Exception('Failed to fetch report, code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetch report: $e')));
        setState(() {
          attendanceData = [];
        });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================== PICK DATE ==================
  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Attendance Report",
          style: TextStyle(color: Color(0xFF29497D), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ================== FILTER ==================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)
                ],
              ),
              child: Column(
                children: [
                  // TextField untuk nama karyawan
                  TextField(
                    controller: employeeController,
                    decoration: const InputDecoration(
                      labelText: "Nama Karyawan",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      selectedEmployeeName = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: selectedDate == null
                                ? "Pilih Tanggal"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: _pickDate,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tombol Cari
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: fetchAttendanceReport,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        "Cari",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29497D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Tombol Reset
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedEmployeeName = null;
                          selectedDate = null;
                          employeeController.clear();
                        });
                        fetchAttendanceReport();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Reset Filter", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ================== TABLE ==================
            // ================== TABLE ==================
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: attendanceData.isEmpty
                        ? const Center(child: Text("Tidak ada data absensi"))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width),
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateProperty.all(const Color(0xFF29497D)),
                                  columns: const [
                                    DataColumn(
                                        label: Text("Nama",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Departemen",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Tanggal",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Clock In",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Clock Out",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Overtime Start",
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text("Overtime End",
                                            style: TextStyle(color: Colors.white))),
                                  ],
                                  rows: attendanceData
                                      .map((e) => DataRow(cells: [
                                            DataCell(Text(e['employee_name'] ?? '-')),
                                            DataCell(Text(e['department'] ?? '-')),
                                            DataCell(Text(e['date'] ?? '-')),
                                            DataCell(Text(e['clock_in'] ?? '-')),
                                            DataCell(Text(e['clock_out'] ?? '-')),
                                            DataCell(Text(e['overtime_start'] ?? '-')),
                                            DataCell(Text(e['overtime_end'] ?? '-')),
                                          ]))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

