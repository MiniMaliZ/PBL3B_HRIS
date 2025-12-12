import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedTime = DateTime.now();
  DateTime? checkIn;
  DateTime? checkOut;

  // jam kerja 08:00 - 16:00
  final workStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8);
  final workEnd = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16);

  bool get hasCheckedIn => checkIn != null;
  bool get hasCheckedOut => checkOut != null;

  /// format jam
  String formatTime(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2,'0')}";

  String _weekdayString(DateTime d) =>
      ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][d.weekday - 1];

  String _monthString(int m) =>
      ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][m - 1];

  String formatWorkingHours() {
    if (checkIn == null || checkOut == null) return "--h --m";

    final diff = checkOut!.difference(checkIn!);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return "${h.toString().padLeft(2,'0')}h ${m.toString().padLeft(2,'0')}m";
  }

  String get clockInStatus {
    if (checkIn == null) return "";
    if (checkIn!.isAfter(workStart)) return "Late";
    if (checkIn!.isBefore(workStart)) return "Early";
    return "On Time";
  }

  String get clockOutStatus {
    if (checkOut != null) return "You're off the clock!";
    return "";
  }

  String get overtimeStatus {
    if (checkIn == null || checkOut == null) return "";

    final totalMinutes = checkOut!.difference(checkIn!).inMinutes;
    final overtime = totalMinutes - (8 * 60); // lebih dari 8 jam

    if (overtime > 15) return "Overtime";
    return "";
  }

  void handlePunch() {
    setState(() {
      if (checkIn == null) {
        checkIn = selectedTime;
      } else if (checkOut == null) {
        checkOut = selectedTime;
      }
    });
  }

  void pickTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
    );
    if (newTime != null) {
      setState(() {
        selectedTime = DateTime(
          selectedTime.year, selectedTime.month, selectedTime.day,
          newTime.hour, newTime.minute);
      });
    }
  }

  void uploadSuratTugas() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Surat Tugas"),
        content: const Text("Dummy upload dialog"),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text("Attendance Page",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // =============== PROFILE ===============
          Row(children: [
            const CircleAvatar(radius: 27),
            const SizedBox(width: 15),

            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Carlene Lim", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xFF424242))),
                Text("UI/UX Designer", style: TextStyle(color: Color(0xFF6F6F6F))),
              ],
            )),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${_weekdayString(selectedTime)}, ${selectedTime.day} "
                  "${_monthString(selectedTime.month)} ${selectedTime.year}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A4A)),
                ),
                Text(formatTime(selectedTime),
                    style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Color(0xFF424242)))
              ],
            )
          ]),

          const SizedBox(height:25),

          // =============== CARD MAIN ===============
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow:[BoxShadow(blurRadius:10,color:Colors.black12,offset: Offset(0,4))]
            ),
            child: Column(children:[

              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                /// CLOCK IN
                attendanceColumn(
                  label:"Clock In",
                  time: checkIn!=null ? formatTime(checkIn!) : "--:--:--",
                  status: checkIn!=null ? clockInStatus : ""
                ),

                /// CLOCK OUT
                attendanceColumn(
                  label:"Clock Out",
                  time: checkOut!=null ? formatTime(checkOut!) : "--:--:--",
                  status: checkOut!=null ? clockOutStatus : ""
                ),

                /// WORKING HOURS
                attendanceColumn(
                  label:"Working Hours",
                  time: checkOut!=null ? formatWorkingHours() : "--h --m",
                  status: checkOut!=null && overtimeStatus.isNotEmpty ? overtimeStatus : ""
                ),
              ]),

              const SizedBox(height:20),

              GestureDetector(
                onTap: pickTime,
                child: Text(formatTime(selectedTime),
                  style: const TextStyle(fontSize:46,fontWeight:FontWeight.bold,color:Color(0xFF424242))),
              ),

              const SizedBox(height:20),

              Row(children:[

                Expanded(child: ElevatedButton(
                  onPressed: handlePunch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFF2AB7A9),
                    padding:const EdgeInsets.symmetric(vertical:15),
                    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
                  ),
                  child:const Text("Clock In",style:TextStyle(color:Colors.white)),
                )),

                const SizedBox(width:12),

                Expanded(child: ElevatedButton(
                  onPressed: hasCheckedIn ? handlePunch : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCheckedIn ? const Color(0xFF29497D) : Colors.grey[350],
                    padding:const EdgeInsets.symmetric(vertical:15),
                    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
                  ),
                  child:const Text("Clock Out",style:TextStyle(color:Colors.white)),
                )),
              ]),
            ]),
          ),

          const SizedBox(height:25),

          ElevatedButton.icon(
            onPressed: uploadSuratTugas,
            icon:const Icon(Icons.upload,color:Colors.white),
            label:const Text("Upload Surat Tugas",style:TextStyle(color:Colors.white)),
            style:ElevatedButton.styleFrom(
              backgroundColor:const Color(0xFF29497D),
              padding:const EdgeInsets.symmetric(vertical:15),
              minimumSize:const Size(double.infinity,45),
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
            ),
          )
        ]),
      ),
    );
  }

  Widget attendanceColumn({required String label, required String time, required String status}) {
    return Column(children:[

      status.isNotEmpty
        ? Text(status,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600))
        : const SizedBox(height:18),

      const SizedBox(height:3),

      Text(time, style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:Color(0xFF3C3C3C))),
      const SizedBox(height:4),
      Text(label,style:const TextStyle(color:Color(0xFF6E6E6E))),
    ]);
  }
}
