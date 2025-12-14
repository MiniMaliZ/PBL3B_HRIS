<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule): void
    {

        // Sync awal Desember untuk tahun berikutnya
        $schedule->command('holidays:sync', ['year' => now()->addYear()->year])
            ->yearlyOn(12, 1, '02:30')
            ->timezone('Asia/Jakarta');
    }
    
    protected function commands(): void
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
