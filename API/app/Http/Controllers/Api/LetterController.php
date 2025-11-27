<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Letter;
use App\Http\Resources\LetterResource;
use App\Http\Resources\LetterCollection;
use Illuminate\Http\Request;

class LetterController extends Controller
{
    public function index()
    {
        $letters = Letter::with('letterFormat')->active()->paginate(10);
        return new LetterCollection($letters);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'letter_format_id' => 'required|uuid|exists:letter_formats,id',
            'user_id' => 'nullable|uuid', // nullable karena sementara
            'name' => 'required|string|max:100',
        ]);

        $letter = Letter::create($validated);
        return new LetterResource($letter);
    }

    public function show($id)
    {
        $letter = Letter::with('letterFormat')->active()->findOrFail($id);
        return new LetterResource($letter);
    }

    public function update(Request $request, $id)
    {
        $letter = Letter::active()->findOrFail($id);
        $validated = $request->validate([
            'letter_format_id' => 'sometimes|uuid|exists:letter_formats,id',
            'user_id' => 'sometimes|nullable|uuid',
            'name' => 'sometimes|string|max:100',
        ]);

        $letter->update($validated);
        return new LetterResource($letter);
    }

    public function destroy($id)
    {
        $letter = Letter::findOrFail($id);
        $letter->deleted_at = now()->format('Y-m-d H:i:s');
        $letter->save();
        return response()->json(['message' => 'deleted']);
    }
}
