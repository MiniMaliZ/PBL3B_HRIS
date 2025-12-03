<?php

namespace Database\Seeders;

use App\Models\Holiday;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class HolidaySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Data libur nasional Indonesia 2025
        $holidays = [
            ['date' => '2025-01-01', 'name' => 'Tahun Baru', 'is_national' => true],
            ['date' => '2025-03-29', 'name' => 'Isra dan Mi\'raj', 'is_national' => true],
            ['date' => '2025-04-10', 'name' => 'Hari Raya Nyepi', 'is_national' => true],
            ['date' => '2025-04-14', 'name' => 'Hari Libur Bersama', 'is_national' => true],
            ['date' => '2025-04-15', 'name' => 'Hari Raya Idul Fitri', 'is_national' => true],
            ['date' => '2025-04-16', 'name' => 'Hari Raya Idul Fitri', 'is_national' => true],
            ['date' => '2025-04-17', 'name' => 'Hari Libur Bersama', 'is_national' => true],
            ['date' => '2025-04-24', 'name' => 'Hari Raya Idul Adha', 'is_national' => true],
            ['date' => '2025-05-01', 'name' => 'Hari Buruh Internasional', 'is_national' => true],
            ['date' => '2025-05-29', 'name' => 'Kenaikan Isa Al-Masih', 'is_national' => true],
            ['date' => '2025-06-01', 'name' => 'Hari Lahir Pancasila', 'is_national' => true],
            ['date' => '2025-06-16', 'name' => 'Hari Raya Waisak', 'is_national' => true],
            ['date' => '2025-08-17', 'name' => 'Hari Kemerdekaan Indonesia', 'is_national' => true],
            ['date' => '2025-12-25', 'name' => 'Hari Natal', 'is_national' => true],
            ['date' => '2025-12-26', 'name' => 'Hari Libur Bersama', 'is_national' => true],
        ];

        foreach ($holidays as $holiday) {
            Holiday::updateOrCreate(
                ['date' => $holiday['date']],
                $holiday
            );
        }

        $this->command->info('✅ Holiday seeder completed!');
    }
}
