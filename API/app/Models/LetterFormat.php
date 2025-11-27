<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class LetterFormat extends Model
{
    protected $table = 'letter_formats';
    protected $keyType = 'string';
    public $incrementing = false;
    protected $fillable = ['name', 'content', 'status'];

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                // Generate custom ID: LF001, LF002, dst
                $lastId = self::orderBy('id', 'desc')->first();
                $number = $lastId ? intval(substr($lastId->id, 2)) + 1 : 1;
                $model->id = 'LF' . str_pad($number, 3, '0', STR_PAD_LEFT);
            }
        });
    }

    // Relasi ke letters
    public function letters()
    {
        return $this->hasMany(Letter::class, 'letter_format_id');
    }

    public function scopeActive($query)
    {
        return $query->whereNull('deleted_at');
    }
}
