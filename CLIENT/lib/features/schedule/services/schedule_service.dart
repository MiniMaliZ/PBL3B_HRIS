import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ScheduleService {
  String? _resolved;

  // Opsi override via dart-define:
  // flutter run --dart-define=BASE_API=http://192.168.1.13:8000/api
  static const String _envBaseApi = String.fromEnvironment('BASE_API');

  // Kandidat runtime (bisa di-set dari UI debug)
  List<String> _customCandidates = [];

  void setCandidates(List<String> candidates) {
    _customCandidates = candidates;
    _resolved = null;
  }

  Future<String> _getBaseUrl() async {
    if (_resolved != null) return _resolved!;

    if (_envBaseApi.isNotEmpty) {
      _resolved = _envBaseApi;
      debugPrint("✅ Using BASE_API from env: $_resolved");
      return _resolved!;
    }

    List<String> candidates;
    if (_customCandidates.isNotEmpty) {
      candidates = List.from(_customCandidates);
    } else if (kIsWeb) {
      candidates = ["http://localhost:8000/api", "http://127.0.0.1:8000/api"];
    } else if (Platform.isAndroid) {
      candidates = [
        // Prioritaskan IP komputer kamu di jaringan 192.168.1.x
        "http://192.168.1.13:8000/api",
        // fallback untuk emulator dan loopback
        "http://10.0.2.2:8000/api",
        "http://127.0.0.1:8000/api",
      ];
    } else if (Platform.isIOS) {
      candidates = [
        "http://192.168.1.13:8000/api",
        "http://localhost:8000/api",
        "http://127.0.0.1:8000/api",
      ];
    } else {
      candidates = ["http://localhost:8000/api", "http://127.0.0.1:8000/api"];
    }

    debugPrint("🔍 Checking API candidates: $candidates");

    for (final c in candidates) {
      try {
        final uri = Uri.parse("$c/schedules");
        final res = await http.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          debugPrint("✅ Using API: $c");
          _resolved = c;
          return c;
        } else {
          debugPrint("⚠️ Candidate $c responded ${res.statusCode}");
        }
      } on SocketException catch (se) {
        debugPrint("❌ Candidate $c failed (SocketException): $se");
      } on HttpException catch (he) {
        debugPrint("❌ Candidate $c failed (HttpException): $he");
      } on FormatException catch (fe) {
        debugPrint("❌ Candidate $c failed (FormatException): $fe");
      } catch (e) {
        debugPrint("❌ Candidate $c failed: $e");
      }
    }

    _resolved = Platform.isAndroid
        ? (candidates.isNotEmpty
              ? candidates.first
              : "http://10.0.2.2:8000/api")
        : (candidates.isNotEmpty
              ? candidates.first
              : "http://localhost:8000/api");

    debugPrint("🔧 Fallback base URL: $_resolved");
    return _resolved!;
  }

  Future<List<dynamic>> fetchHolidays({int? year}) async {
    try {
      final root = await _getBaseUrl();
      final url = year != null
          ? "$root/schedules?year=$year"
          : "$root/schedules";
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body is List ? body : [];
      }
      debugPrint("⚠️ fetchHolidays non-200: ${res.statusCode} ${res.body}");
      return [];
    } catch (e) {
      debugPrint("❌ ERROR fetchHolidays: $e");
      return [];
    }
  }

  Future<bool> addHoliday(String date, String name) async {
    try {
      final root = await _getBaseUrl();
      final uri = Uri.parse("$root/schedules");
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'date': date, 'name': name}),
          )
          .timeout(const Duration(seconds: 8));
      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok)
        debugPrint("⚠️ addHoliday failed: ${res.statusCode} ${res.body}");
      return ok;
    } catch (e) {
      debugPrint("❌ ERROR addHoliday: $e");
      return false;
    }
  }

  Future<bool> deleteHoliday(int id) async {
    try {
      final root = await _getBaseUrl();
      final res = await http
          .delete(Uri.parse("$root/schedules/$id"))
          .timeout(const Duration(seconds: 8));
      final ok = res.statusCode == 200 || res.statusCode == 204;
      if (!ok)
        debugPrint("⚠️ deleteHoliday failed: ${res.statusCode} ${res.body}");
      return ok;
    } catch (e) {
      debugPrint("❌ ERROR deleteHoliday: $e");
      return false;
    }
  }

  Future<void> syncNationalHolidays(int year) async {
    try {
      final root = await _getBaseUrl();
      final res = await http
          .get(Uri.parse("$root/schedules/sync?year=$year"))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        debugPrint("✅ Sync selesai: ${res.body}");
      } else {
        debugPrint("❌ Sync gagal: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      debugPrint("❌ ERROR syncNationalHolidays: $e");
    }
  }
}
