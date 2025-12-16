<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\ScheduleController;

Route::prefix('schedules')->group(function () {
    Route::get('/', [ScheduleController::class, 'index']);                   // GET /api/schedules?year=YYYY
    Route::get('/sync', [ScheduleController::class, 'sync']);               // GET /api/schedules/sync?year=YYYY
    Route::get('/month/{month}', [ScheduleController::class, 'byMonth']);   // GET /api/schedules/month/12?year=2025
    Route::get('/is-holiday/{date}', [ScheduleController::class, 'isHoliday']); // GET /api/schedules/is-holiday/2025-12-25
    Route::post('/', [ScheduleController::class, 'store']);                 // POST /api/schedules
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);         // DELETE /api/schedules/{id}
});

Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);
