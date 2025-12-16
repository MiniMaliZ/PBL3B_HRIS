<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Department extends Model
{
    protected $table = 'department'; // pastikan nama tabel sesuai database
    protected $fillable = [
        'name',
        'radius',         // misal: "50" meter
        'latitude',       // tambahkan kolom ini di migration!
        'longitude'       // tambahkan kolom ini di migration!
    ];

    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }
}
