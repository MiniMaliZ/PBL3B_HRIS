<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LetterFormat;
use Illuminate\Http\Request;

class LetterFormatController extends Controller
{
    public function index()
    {
        $formats = LetterFormat::all();
        return $this->success($formats, 'Daftar format surat');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'content' => 'required|string'
        ]);

        $format = LetterFormat::create($validated);
        return $this->success($format, 'Format surat berhasil dibuat');
    }
}
