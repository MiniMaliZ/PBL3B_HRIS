<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Holiday extends Model
{
    protected $fillable = ['date', 'name', 'is_national'];

    protected $casts = [
        'is_national' => 'boolean',
    ];

    // Override toArray to ensure date is Y-m-d format
    public function toArray()
    {
        $array = parent::toArray();
        
        // Ensure date is always Y-m-d string format
        if (isset($array['date'])) {
            if ($array['date'] instanceof \DateTime) {
                $array['date'] = $array['date']->format('Y-m-d');
            } elseif (is_string($array['date']) && strpos($array['date'], 'T') !== false) {
                // If it's ISO 8601 format, convert to Y-m-d
                try {
                    $date = new \DateTime($array['date']);
                    $array['date'] = $date->format('Y-m-d');
                } catch (\Exception $e) {
                    // Keep original if parsing fails
                }
            }
            // If it's already Y-m-d format, keep it as is
        }
        
        return $array;
    }
}
