<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LetterFormat extends Model
{
    use HasFactory;

    protected $table = 'letter_formats';

    protected $fillable = [
        'name',
        'content',
    ];

    public function letters()
    {
        return $this->hasMany(Letter::class);
    }
}
