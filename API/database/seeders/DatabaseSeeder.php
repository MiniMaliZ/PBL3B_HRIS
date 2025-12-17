<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Department;
use App\Models\Employee;
use App\Models\User;
use App\Models\Position;
use App\Models\LetterFormat;
use App\Models\CheckClock;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $this->command->info('🔄 Starting seeding...');

        // -----------------------------
        // 1. Buat positions
        // -----------------------------
        $this->command->info('📝 Creating positions...');
        Position::create([
            'name' => 'Manager',
            'rate_reguler' => 50000,
            'rate_overtime' => 75000
        ]);
        Position::create([
            'name' => 'Senior Developer',
            'rate_reguler' => 40000,
            'rate_overtime' => 60000
        ]);
        Position::create([
            'name' => 'Junior Developer',
            'rate_reguler' => 30000,
            'rate_overtime' => 45000
        ]);
        Position::create([
            'name' => 'Staff',
            'rate_reguler' => 25000,
            'rate_overtime' => 37500
        ]);
        $this->command->info('✅ Positions created: ' . Position::count());

        // -----------------------------
        // 2. Buat departments
        // -----------------------------
        $this->command->info('🏢 Creating departments...');
        Department::create([
            'name' => 'IT Department',
            'radius' => '50',
            'latitude' => -6.2088,
            'longitude' => 106.8456
        ]);
        Department::create([
            'name' => 'HR Department',
            'radius' => '50',
            'latitude' => -6.2088,
            'longitude' => 106.8456
        ]);
        Department::create([
            'name' => 'Finance Department',
            'radius' => '50',
            'latitude' => -6.2088,
            'longitude' => 106.8456
        ]);
        $this->command->info('✅ Departments created: ' . Department::count());

        // -----------------------------
        // 3. Buat letter formats
        // -----------------------------
        $this->command->info('📄 Creating letter formats...');
        LetterFormat::create([
            'name' => 'Surat Izin Sakit',
            'content' => 'Template surat izin sakit...'
        ]);
        LetterFormat::create([
            'name' => 'Surat Izin Cuti',
            'content' => 'Template surat izin cuti...'
        ]);
        LetterFormat::create([
            'name' => 'Surat Keterangan',
            'content' => 'Template surat keterangan...'
        ]);
        $this->command->info('✅ Letter formats created: ' . LetterFormat::count());

        // -----------------------------
        // 4. Buat users dan employees
        // -----------------------------
        $this->command->info('👤 Creating users and employees...');

        $employeesArr = [];

        // Admin
        $user1 = User::create([
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'is_admin' => true,
        ]);
        $employeesArr[] = Employee::create([
            'user_id' => $user1->id,
            'position_id' => 1,
            'department_id' => 1,
            'first_name' => 'Admin',
            'last_name' => 'System',
            'gender' => 'M',
            'address' => 'Jakarta Pusat'
        ]);

        // User 2
        $user2 = User::create([
            'email' => 'john.doe@example.com',
            'password' => bcrypt('password'),
            'is_admin' => false,
        ]);
        $employeesArr[] = Employee::create([
            'user_id' => $user2->id,
            'position_id' => 2,
            'department_id' => 1,
            'first_name' => 'John',
            'last_name' => 'Doe',
            'gender' => 'M',
            'address' => 'Jakarta Selatan'
        ]);

        // User 3
        $user3 = User::create([
            'email' => 'jane.smith@example.com',
            'password' => bcrypt('password'),
            'is_admin' => false,
        ]);
        $employeesArr[] = Employee::create([
            'user_id' => $user3->id,
            'position_id' => 3,
            'department_id' => 2,
            'first_name' => 'Jane',
            'last_name' => 'Smith',
            'gender' => 'F',
            'address' => 'Jakarta Utara'
        ]);

        // User 4
        $user4 = User::create([
            'email' => 'bob.wilson@example.com',
            'password' => bcrypt('password'),
            'is_admin' => false,
        ]);
        $employeesArr[] = Employee::create([
            'user_id' => $user4->id,
            'position_id' => 4,
            'department_id' => 3,
            'first_name' => 'Bob',
            'last_name' => 'Wilson',
            'gender' => 'M',
            'address' => 'Jakarta Barat'
        ]);

        // User 5
        $user5 = User::create([
            'email' => 'alice.brown@example.com',
            'password' => bcrypt('password'),
            'is_admin' => false,
        ]);
        $employeesArr[] = Employee::create([
            'user_id' => $user5->id,
            'position_id' => 2,
            'department_id' => 1,
            'first_name' => 'Alice',
            'last_name' => 'Brown',
            'gender' => 'F',
            'address' => 'Jakarta Timur'
        ]);

        $this->command->info('✅ Users created: ' . User::count());
        $this->command->info('✅ Employees created: ' . Employee::count());

        // -----------------------------
        // 5. Attendance (CheckClock) dummy
        // -----------------------------
        $this->command->info('⏰ Creating attendance records...');
        $dates = collect(range(0, 4))->map(fn($i) => Carbon::now()->subDays($i)); // 5 hari terakhir
        foreach ($employeesArr as $emp) {
            foreach ($dates as $date) {
                CheckClock::create([
                    'employee_id' => $emp->id,
                    'employee_name' => $emp->first_name . ' ' . $emp->last_name,
                    'date' => $date->format('Y-m-d'),
                    'clock_in' => '08:00:00',
                    'clock_out' => '17:00:00',
                    'overtime_start' => '17:15:00',
                    'overtime_end' => '19:00:00',
                    'check_clock_type' => 1,
                    'latitude' => 0.0,
                    'longitude' => 0.0,
                ]);
            }
        }
        $this->command->info('✅ Attendance records created for all employees.');

        $this->command->info('');
        $this->command->info('✅ Database seeded successfully!');
        $this->command->info('📧 Admin: admin@example.com | Password: password');
        $this->command->info('👤 Total Employees: ' . Employee::count());
        $this->command->info('🏢 Total Departments: ' . Department::count());
        $this->command->info('💼 Total Positions: ' . Position::count());
        $this->command->info('📄 Total Letter Formats: ' . LetterFormat::count());
    }
}
