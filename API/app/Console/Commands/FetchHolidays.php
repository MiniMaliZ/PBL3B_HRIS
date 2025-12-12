<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use App\Models\Holiday;


class FetchHolidays extends Command
{
    protected $signature = 'app:fetch-holidays';
    protected $description = 'Fetch Indonesian national holidays and store them into database';

    public function handle()
    {
        $this->info("Fetching Indonesian national holidays...");

        $response = Http::get("https://dayoffapi.vercel.app/api");

        if ($response->failed()) {
            $this->error("Failed to fetch data!");
            return Command::FAILURE;
        }

        $holidays = $response->json();

        foreach ($holidays as $holiday) {
            Holiday::updateOrCreate(
                ['date' => $holiday['tanggal']],
                [
                    'name' => $holiday['keterangan'],
                    'is_national' => true
                ]
            );
        }

        $this->info("National holidays stored/updated successfully!");
        return Command::SUCCESS;
    }
}
