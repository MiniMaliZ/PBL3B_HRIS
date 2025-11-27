<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Letter extends Model
{
    protected $table = 'letters';
    protected $keyType = 'string';
    public $incrementing = false;
    protected $fillable = ['letter_format_id', 'user_id', 'name'];

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                // Generate custom ID: LTR001, LTR002, dst
                $lastId = self::orderBy('id', 'desc')->first();
                $number = $lastId ? intval(substr($lastId->id, 3)) + 1 : 1;
                $model->id = 'LTR' . str_pad($number, 3, '0', STR_PAD_LEFT);
            }
        });
    }

    // Relasi
    public function letterFormat()
    {
        return $this->belongsTo(LetterFormat::class, 'letter_format_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id'); // nanti kalau User model sudah ada
    }

    // Custom soft delete (karena deleted_at varchar)
    public function scopeActive($query)
    {
        return $query->whereNull('deleted_at');
    }
}
