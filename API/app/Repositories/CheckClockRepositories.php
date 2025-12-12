<?php

namespace App\Repositories;

class CheckClockRepository
{
    private array $data;

    public function __construct()
    {
        // Data seolah dari seeder
        $this->data = include base_path('database/seeders/data/CheckClockSeeder.php');
    }

    public function all()
    {
        return $this->data;
    }

    public function findByUser($userId)
    {
        return array_values(array_filter($this->data, function ($item) use ($userId) {
            return $item['user_id'] == $userId;
        }));
    }
}
