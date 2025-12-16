<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class EmployeeSeeder extends Seeder
{
    public function run()
    {
        DB::table('employee')->insert([
            [
                'id' => 1,
                'name' => 'Karyawan 1',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'Karyawan 2',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
