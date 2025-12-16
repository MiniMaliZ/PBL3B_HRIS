<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::table('check_clocks', function (Blueprint $table) {
        $table->string('employee_name')->after('employee_id');
    });
}

public function down()
{
    Schema::table('check_clocks', function (Blueprint $table) {
        $table->dropColumn('employee_name');
    });
}

};
