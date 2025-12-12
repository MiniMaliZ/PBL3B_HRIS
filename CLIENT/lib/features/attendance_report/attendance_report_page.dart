import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/app_drawer.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  List<dynamic> employees = [];
  List<String> employeeNames = [];
  String? selectedEmployee;
  DateTime? selectedDate;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

Future<void> fetchEmployees() async {
  setState(() => loading = true);

  // base URL
  String url = 'http://localhost:8000/api/check-clocks';

  // tambah query parameter IF ada filter
  Map<String, String> query = {};

  if (selectedEmployee != null && selectedEmployee!.isNotEmpty) {
    query['employee_name'] = selectedEmployee!;
  }

  if (selectedDate != null) {
    query['date'] =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
  }

  final uri = Uri.parse(url).replace(queryParameters: query);

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        employees = data;

        // ambil daftar nama untuk dropdown (supaya tetap dinamis)
        employeeNames = employees
            .map<String>((e) => (e['employee_name'] ?? 'Unknown') as String)
            .toSet()
            .toList();
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => loading = false);
  }
}
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
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
          style: TextStyle(
            color: Color(0xFF29497D),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ===================== FILTER =====================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                children: [
                  Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    // Jika kosong → tampilkan semua nama
                    if (textEditingValue.text.isEmpty) {
                      return employeeNames;
                    }

                    // Filter berdasarkan input
                    final results = employeeNames.where((name) =>
                        name.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    ).toList();

                    // Jika tidak ada hasil, tampilkan semua nama
                    if (results.isEmpty) {
                      return employeeNames;
                    }

                    return results;
                  },
                  onSelected: (String selection) {
                    setState(() => selectedEmployee = selection);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: "Cari Karyawan",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => selectedEmployee = null);
                      },
                    );
                  },
                ),


                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: fetchEmployees,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        "Cari",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29497D),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===================== TABLE =====================
            loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFF29497D),
                            ),
                            columns: const [
                              DataColumn(
                                label: Text("Employee ID",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Employee Name",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Tanggal",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Clock In",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Clock Out",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Overtime Start",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Overtime End",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                            rows: employees.map((e) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(e['employee_id'].toString())),
                                  DataCell(Text(e['employee_name'] ?? '-')),  
                                  DataCell(Text(e['date'] ?? '-')),
                                  DataCell(Text(e['clock_in'] ?? '-')),
                                  DataCell(Text(e['clock_out'] ?? '-')),
                                  DataCell(Text(e['overtime_start'] ?? '-')),
                                  DataCell(Text(e['overtime_end'] ?? '-')),
                                ],
                              );
                            }).toList(),
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
