<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\CheckClockController;

Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);

Route::get('/check-clocks', [CheckClockController::class, 'index']);
Route::get('/check-clocks/{userId}', [CheckClockController::class, 'show']);

