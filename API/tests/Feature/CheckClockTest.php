<?php

namespace Tests\Feature;

use Tests\TestCase;     // ⬅️ WAJIB
use Illuminate\Foundation\Testing\RefreshDatabase;

class CheckClockTest extends TestCase
{
    use RefreshDatabase;

    public function test_get_check_clocks()
{
    $response = $this->getJson('/api/check-clocks');

    $response->assertStatus(200)
             ->assertJsonStructure([
                 '*' => [
                     'employee_id',
                     'employee_name',
                     'date'
                 ]
             ]);
}

    public function test_get_check_clock_data_from_database()
{
    $response = $this->getJson('/api/check-clocks');

    $response->assertStatus(200)
             ->assertJsonStructure([
                 '*' => [
                     'employee_id',
                    'employee_name',
                    'check_clock_type',
                    'date',
                    'clock_in',
                    'clock_out',
                    'overtime_start',
                    'overtime_end',
                    'created_at',
                    'updated_at',
                 ]
             ]);
}

}
