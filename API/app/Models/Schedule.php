<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

class Schedule extends Model
{
    protected $table = 'schedules';
    protected $fillable = ['date', 'name'];
    protected $casts = [
        'date' => 'date:Y-m-d',
    ];

    public function scopeForYear(Builder $query, int $year): Builder
    {
        return $query->whereYear('date', $year)->orderBy('date');
    }

    public static function isHoliday(string|\DateTimeInterface $date): bool
    {
        $d = is_string($date) ? $date : Carbon::parse($date)->toDateString();
        return static::whereDate('date', $d)->exists();
    }
}
