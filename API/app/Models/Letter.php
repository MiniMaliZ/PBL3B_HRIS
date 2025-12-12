<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Letter extends Model
{
    use HasFactory;

    protected $fillable = [
        'letter_format_id',
        'employee_id',
        'name',
        'status',
    ];

    protected $casts = [
        'status' => 'integer',
    ];

    public function letterFormat()
    {
        return $this->belongsTo(LetterFormat::class);
    }

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}
