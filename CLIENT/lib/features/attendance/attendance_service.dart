import 'attendance_model.dart';

class AttendanceService {
  Attendance attendance = Attendance();

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  /// punch otomatis:
  /// - kalau belum check in ⇒ check in
  /// - kalau sudah check in ⇒ check out
  void punch() {
    final now = DateTime.now();

    if (attendance.checkIn == null ||
        !isSameDay(attendance.checkIn!, now)) {
      attendance.checkIn = now;
      attendance.checkOut = null;
    } else if (attendance.checkOut == null) {
      attendance.checkOut = now;
    }
  }
}
