<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CheckClockSeeder extends Seeder
{
    public function run()
    {
        DB::table('check_clocks')->insert([
            [
                'employee_id'      => 1,
                'employee_name'    => 'Paijo',
                'check_clock_type' => 0,
                'date'             => '2025-01-01',
                'clock_in'         => '08:00:00',
                'clock_out'        => '17:00:00',
                'overtime_start'   => null,
                'overtime_end'     => null,
                'created_at'       => Carbon::now(),
                'updated_at'       => Carbon::now(),
            ],
            [
                'employee_id'      => 2,
                'employee_name'    => 'Tono',
                'check_clock_type' => 1,
                'date'             => '2025-01-02',
                'clock_in'         => '08:05:00',
                'clock_out'        => '17:00:00',
                'overtime_start'   => '17:30:00',
                'overtime_end'     => '19:00:00',
                'created_at'       => Carbon::now(),
                'updated_at'       => Carbon::now(),
            ],
            [
                'employee_id'      => 3,
                'employee_name'    => 'Sigit',
                'check_clock_type' => 0,
                'date'             => '2025-01-01',
                'clock_in'         => '09:12:00',
                'clock_out'        => '17:00:00',
                'overtime_start'   => null,
                'overtime_end'     => null,
                'created_at'       => Carbon::now(),
                'updated_at'       => Carbon::now(),
            ],
        ]);
    }
}
