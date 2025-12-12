<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\LetterFormatController;

/*
|--------------------------------------------------------------------------
| Attendance API Routes - NEW
|--------------------------------------------------------------------------
*/

// 1. Submit Attendance (clock_in / clock_out / overtime_start / overtime_end)
Route::post('/attendance/submit', [AttendanceController::class, 'store']);

// 2. Get Department Location (untuk inisialisasi frontend)
Route::get('/department/location/{employeeId}', [AttendanceController::class, 'getDepartmentLocation']);

// 3. Get Attendance History (untuk tampilkan riwayat)
Route::get('/attendance/history/{employeeId}', [AttendanceController::class, 'getHistory']);

/*
|--------------------------------------------------------------------------
| Letter API Routes - EXISTING
|--------------------------------------------------------------------------
*/

Route::apiResource('/letters', LetterController::class);
Route::apiResource('/letter-formats', LetterFormatController::class);
