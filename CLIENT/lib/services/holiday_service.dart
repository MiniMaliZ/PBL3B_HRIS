import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HolidayService {
  final String baseUrl = "http://192.168.65.75:8000/api";
  String? _resolvedBaseUrl;

  // Try several candidate base URLs (local dev, emulator, localhost)
  Future<String> _getBaseUrl() async {
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;
    // Build candidate list. On Android prefer emulator loopback address.
    final defaultCandidates = [
      baseUrl,
      'http://10.0.2.2:8000/api', // Android emulator
      'http://localhost:8000/api',
      'http://127.0.0.1:8000/api',
    ];

    final candidates = <String>[];
    if (Platform.isAndroid) {
      // For Android emulators, prefer 10.0.2.2 which maps to host localhost
      candidates.add('http://10.0.2.2:8000/api');
      // then try configured host IP and loopback options
      candidates.addAll(defaultCandidates.where((c) => c != 'http://10.0.2.2:8000/api'));
    } else {
      candidates.addAll(defaultCandidates);
    }

    print('BaseURL probe candidates: $candidates (Platform.isAndroid=${Platform.isAndroid})');

    for (final c in candidates) {
      try {
        print('Checking base URL: $c');
        final uri = Uri.parse('$c/holidays');
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          _resolvedBaseUrl = c;
          print('Using API base URL: $_resolvedBaseUrl');
          return _resolvedBaseUrl!;
        }
        print('Non-200 from $c: ${res.statusCode}');
      } catch (e) {
        print('BaseURL check failed for $c: $e');
      }
    }

    // fallback to configured baseUrl
    _resolvedBaseUrl = baseUrl;
    print('Falling back to configured baseUrl: $_resolvedBaseUrl');
    return _resolvedBaseUrl!;
  }

  // Public accessor to know which base URL was resolved (for debugging)
  Future<String> getResolvedBaseUrl() async {
    return await _getBaseUrl();
  }

  // Allow tests / UI to set a manual base URL (override probe)
  void setResolvedBaseUrl(String? url) {
    if (url == null || url.isEmpty) {
      _resolvedBaseUrl = null;
      print('Resolved base URL cleared by user.');
    } else {
      _resolvedBaseUrl = url;
      print('Resolved base URL set by user: $_resolvedBaseUrl');
    }
  }

  // Ambil semua libur dari database Laravel
  Future<List<dynamic>> getNationalHolidays() async {
    try {
      final root = await _getBaseUrl();
      final response = await http.get(
        Uri.parse("$root/holidays"),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Holidays loaded from $root: ${data is List ? data.length : 0} items');
        return data;
      } else {
        print('❌ Error fetching holidays from $root: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching holidays: $e');
      return [];
    }
  }

  // Tambah libur manual
  Future<bool> addHoliday(String date, String name) async {
    try {
      final root = await _getBaseUrl();
      final res = await http.post(
        Uri.parse("$root/holidays"),
        body: {"date": date, "name": name},
      ).timeout(const Duration(seconds: 15));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error adding holiday: $e');
      return false;
    }
  }

  // Get libur berdasarkan bulan
  Future<List<dynamic>> getHolidayByMonth(int month) async {
    try {
      final root = await _getBaseUrl();
      final res = await http
          .get(Uri.parse("$root/holidays/month/$month"))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching holidays by month: $e');
      return [];
    }
  }

  // Get libur berdasarkan bulan dan tahun
  Future<List<dynamic>> getHolidayByMonthYear(int month, int year) async {
    try {
      final root = await _getBaseUrl();
      Uri uri;
      if (month == 0) {
        // request all holidays for the year
        uri = Uri.parse("$root/holidays?year=$year");
      } else {
        uri = Uri.parse("$root/holidays/month/$month?year=$year");
      }

      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Error fetching holidays by month/year: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching holidays by month/year: $e');
      return [];
    }
  }

  // Sinkronisasi libur nasional ke database Laravel
  Future<Map<String, dynamic>> syncNationalHolidays([int? currentYear]) async {
    try {
      print('🔄 Starting sync national holidays...');
      final root = await _getBaseUrl();
      final response = await http.get(
        Uri.parse("$root/holidays/fetch-national"),
      ).timeout(const Duration(seconds: 30));

      print('📊 Sync response status: ${response.statusCode}');
      print('📊 Sync response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Sync successful: ${data['synced_count']} holidays synced');
        return {
          'success': true,
          'message': data['message'] ?? 'Sinkronisasi berhasil',
          'data': data['data'] ?? data,
          'synced_count': data['synced_count'] ?? 0
        };
      } else {
        print('❌ Sync failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Gagal sinkronisasi dari server (${response.statusCode})',
          'data': null,
          'synced_count': 0
        };
      }
    } catch (e) {
      print('❌ Sync error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': null,
        'synced_count': 0
      };
    }
  }

  // Hapus libur berdasarkan id
  Future<bool> deleteHoliday(dynamic id) async {
    try {
      final root = await _getBaseUrl();
      final res = await http
          .delete(Uri.parse("$root/holidays/$id"))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 204) {
        return true;
      }

      print('Error deleting holiday: ${res.statusCode} - ${res.body}');
      return false;
    } catch (e) {
      print('Exception deleting holiday: $e');
      return false;
    }
  }

  Future fetchHolidays() async {}
}
