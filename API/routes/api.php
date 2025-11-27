<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;

Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);
