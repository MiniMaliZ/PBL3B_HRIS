<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\HolidaySyncService;

class SyncHolidays extends Command
{
    protected $signature = 'holidays:sync {year?} {--from=} {--to=}';
    protected $description = 'Sync holidays from Google Calendar ICS for a specific year or range of years';

    public function handle(HolidaySyncService $sync)
    {
        $year = $this->argument('year');
        $from = $this->option('from');
        $to   = $this->option('to');

        if ($year) {
            $count = $sync->syncYear((int)$year);
            $this->info("✅ Synced {$count} schedules for year {$year}");
            return;
        }

        if ($from && $to) {
            for ($y = (int)$from; $y <= (int)$to; $y++) {
                $count = $sync->syncYear($y);
                $this->info("✅ Synced {$count} schedules for year {$y}");
            }
            return;
        }

        $now = now()->year;
        foreach ([$now - 3, $now - 2, $now - 1, $now, $now + 1, $now + 2] as $y) {
            $count = $sync->syncYear($y);
            $this->info("✅ Synced {$count} schedules for year {$y}");
        }
    }
}
