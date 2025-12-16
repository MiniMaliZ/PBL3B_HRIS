<?php

namespace App\Services;

use App\Models\Schedule;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class HolidaySyncService
{
    private string $icsUrl = 'https://calendar.google.com/calendar/ical/en.indonesian%23holiday%40group.v.calendar.google.com/public/basic.ics';
    private Client $http;

    public function __construct()
    {
        $this->http = new Client([
            'timeout' => 10,
            'verify' => true, // set false only for debugging SSL issues (not recommended)
        ]);
    }

    public function syncYear(int $year): int
    {
        try {
            $res = $this->http->get($this->icsUrl);
            if ($res->getStatusCode() !== 200) {
                Log::error('HolidaySync: ICS HTTP status not 200', ['status' => $res->getStatusCode()]);
                return 0;
            }

            $body = (string) $res->getBody();
            $events = $this->parseIcsEvents($body);

            Log::info('HolidaySync: total events parsed: ' . count($events));

            $count = 0;
            foreach ($events as $ev) {
                // ev: ['dtstart' => '20251225' or '2025-12-25', 'summary' => 'Hari Raya']
                $dateRaw = $ev['dtstart'] ?? null;
                $name = $ev['summary'] ?? null;
                if (!$dateRaw || !$name) {
                    Log::warning('HolidaySync: skipping invalid event', ['event' => $ev]);
                    continue;
                }

                // Normalisasi tanggal: dukung format YYYYMMDD dan YYYY-MM-DD
                try {
                    if (preg_match('/^\d{8}$/', $dateRaw)) {
                        $date = Carbon::createFromFormat('Ymd', $dateRaw)->toDateString();
                    } else {
                        $date = Carbon::parse($dateRaw)->toDateString();
                    }
                } catch (\Throwable $e) {
                    Log::warning('HolidaySync: invalid date format', ['dateRaw' => $dateRaw, 'error' => $e->getMessage()]);
                    continue;
                }

                $eventYear = (int)substr($date, 0, 4);
                if ($eventYear !== $year) {
                    // skip events not in requested year
                    continue;
                }

                try {
                    Schedule::updateOrCreate(
                        ['date' => $date],
                        ['name' => $name]
                    );
                    $count++;
                } catch (\Throwable $e) {
                    Log::error('HolidaySync: DB save failed', ['error' => $e->getMessage(), 'date' => $date, 'name' => $name]);
                }
            }

            Log::info("HolidaySync: synced {$count} events for year {$year}");
            return $count;
        } catch (\Throwable $e) {
            Log::error('HolidaySync: exception fetching/parsing ICS', ['error' => $e->getMessage()]);
            return 0;
        }
    }

    /**
     * Parse ICS content and return array of events with dtstart and summary.
     */
    private function parseIcsEvents(string $ics): array
    {
        $lines = preg_split("/\r\n|\n|\r/", $ics);
        $events = [];
        $inEvent = false;
        $current = [];

        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === 'BEGIN:VEVENT') {
                $inEvent = true;
                $current = [];
                continue;
            }
            if ($line === 'END:VEVENT') {
                $inEvent = false;
                // normalize keys to lowercase
                $events[] = array_change_key_case($current, CASE_LOWER);
                $current = [];
                continue;
            }
            if (!$inEvent) {
                continue;
            }

            // unfold folded lines: lines starting with space or tab are continuation
            // (we assume input already has unfolded lines; if not, a pre-processing step needed)

            // split at first colon to separate key and value
            $pos = strpos($line, ':');
            if ($pos === false) {
                continue;
            }
            $key = substr($line, 0, $pos);
            $value = substr($line, $pos + 1);

            // remove parameters from key (e.g., DTSTART;VALUE=DATE -> DTSTART)
            $key = explode(';', $key)[0];

            // store
            $current[$key] = $value;
        }

        // Map to simpler shape: dtstart and summary
        $mapped = [];
        foreach ($events as $e) {
            $mapped[] = [
                'dtstart' => $e['dtstart'] ?? ($e['dtstart;value=date'] ?? null),
                'summary' => $e['summary'] ?? null,
            ];
        }

        return $mapped;
    }
}
