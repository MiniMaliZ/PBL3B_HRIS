<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Letter;
use Illuminate\Http\Request;

class LetterController extends Controller
{
    public function index()
    {
        $letters = Letter::with(['employee', 'letterFormat'])->get();
        return $this->success($letters, 'Daftar surat');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'letter_format_id' => 'required|exists:letter_formats,id',
            'employee_id' => 'required|exists:employees,id',
            'name' => 'required|string',
            'status' => 'required|integer'
        ]);

        $letter = Letter::create($validated);
        return $this->success($letter, 'Surat berhasil dibuat');
    }
}
