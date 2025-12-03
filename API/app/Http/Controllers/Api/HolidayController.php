<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Holiday;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;


class HolidayController extends Controller
{
    // Ambil data libur dari DB
    public function index()
    {
        return Holiday::orderBy('date', 'asc')->get();
    }

    // Fetch libur nasional langsung dari API luar
    public function fetchNational()
    {
        $response = Http::get("https://dayoffapi.vercel.app/api");
        return $response->json();
    }

    // Sync libur nasional ke database lokal
    public function syncNational()
    {
        try {
            // Coba ambil dari API dengan timeout
            $response = Http::timeout(10)->get("https://dayoffapi.vercel.app/api");

            if ($response->failed()) {
                return response()->json([
                    'message' => 'Gagal mengambil data dari API eksternal',
                    'status' => 'error',
                    'synced_count' => 0
                ], 500);
            }

            $holidays = $response->json();
            
            // Validasi response bukan kosong
            if (empty($holidays)) {
                return response()->json([
                    'message' => 'API eksternal mengembalikan data kosong',
                    'status' => 'error',
                    'synced_count' => 0
                ], 400);
            }

            $synced = 0;

            foreach ($holidays as $holiday) {
                // Map field dari API ke database
                $date = $holiday['tanggal'] ?? null;
                $name = $holiday['keterangan'] ?? null;
                
                if (!$date || !$name) {
                    continue; // Skip jika field tidak lengkap
                }

                Holiday::updateOrCreate(
                    ['date' => $date],
                    [
                        'name' => $name,
                        'is_national' => true
                    ]
                );
                $synced++;
            }

            return response()->json([
                'message' => "Berhasil sinkronkan $synced hari libur nasional",
                'status' => 'success',
                'synced_count' => $synced,
                'data' => Holiday::orderBy('date', 'asc')->get()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error: ' . $e->getMessage(),
                'status' => 'error',
                'synced_count' => 0
            ], 500);
        }
    }

    // CREATE libur
    public function store(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'name' => 'required|string',
        ]);

        return Holiday::create([
            'date' => $request->date,
            'name' => $request->name,
            'is_national' => $request->is_national ?? false,
        ]);
    }

    // 🔥 FILTER berdasarkan bulan (1-12)
    public function filterByMonth(Request $request, $month)
    {
        $year = $request->query('year');

        $query = Holiday::whereMonth('date', $month);

        if ($year) {
            $query->whereYear('date', $year);
        }

        $holidays = $query->orderBy('date', 'asc')->get();

        return response()->json($holidays);
    }

    // 🔥 EDIT libur
    public function update(Request $request, $id)
    {
        $holiday = Holiday::findOrFail($id);

        $holiday->update([
            'date' => $request->date ?? $holiday->date,
            'name' => $request->name ?? $holiday->name,
            'is_national' => $request->is_national ?? $holiday->is_national,
        ]);

        return response()->json([
            'message' => 'Holiday updated successfully',
            'data' => $holiday
        ]);
    }

    // 🔥 DELETE libur
    public function destroy($id)
    {
        $holiday = Holiday::findOrFail($id);
        $holiday->delete();

        return response()->json([
            'message' => 'Holiday deleted successfully'
        ]);
    }
}
