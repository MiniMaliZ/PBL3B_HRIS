<?php

namespace App\Http\Controllers;

use App\Models\CheckClock;
use Illuminate\Http\Request;

class CheckClockController extends Controller
{
    public function index(Request $request)
{
    $query = CheckClock::query();

    if ($request->employee_name) {
        $query->where('employee_name', $request->employee_name);
    }

    if ($request->date) {
        $query->whereDate('date', $request->date);
    }

    return response()->json($query->get());
}

}
