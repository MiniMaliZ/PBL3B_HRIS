<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LetterFormat;
use App\Http\Resources\LetterFormatResource;
use App\Http\Resources\LetterFormatCollection;
use Illuminate\Http\Request;

class LetterFormatController extends Controller
{
    public function index()
    {
        $formats = LetterFormat::active()->paginate(10);
        return new LetterFormatCollection($formats);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'content' => 'required',
            'status' => 'required|integer',
        ]);

        $format = LetterFormat::create($validated);
        return new LetterFormatResource($format);
    }

    public function show($id)
    {
        $format = LetterFormat::active()->findOrFail($id);
        return new LetterFormatResource($format);
    }

    public function update(Request $request, $id)
    {
        $format = LetterFormat::active()->findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|string|max:100',
            'content' => 'sometimes',
            'status' => 'sometimes|integer',
        ]);

        $format->update($validated);
        return new LetterFormatResource($format);
    }

    public function destroy($id)
    {
        $format = LetterFormat::findOrFail($id);
        $format->deleted_at = now()->format('Y-m-d H:i:s'); // custom soft delete
        $format->save();
        return response()->json(['message' => 'deleted']);
    }
}
