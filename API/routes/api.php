<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\HolidayController;

Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);
Route::get('/holidays', [HolidayController::class, 'index']);
Route::post('/holidays', [HolidayController::class, 'store']);
Route::get('/national-holidays', [HolidayController::class, 'fetchNational']);
Route::get('/holidays/fetch-national', [HolidayController::class, 'syncNational']);
Route::get('/holidays/month/{month}', [HolidayController::class, 'filterByMonth']);
Route::put('/holidays/{id}', [HolidayController::class, 'update']);
Route::delete('/holidays/{id}', [HolidayController::class, 'destroy']);
