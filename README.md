# check_mssql
## Information
For this to work you need to install:

- unixODBC(http://www.unixodbc.org/) 
- Perl DBD::ODBC (http://search.cpan.org/~mjevans/DBD-ODBC-1.52/ODBC.pm) 
- Microsoft ODBC Driver (https://www.microsoft.com/en-us/download/details.aspx?id=36437)

## check_mssql_uptime.pl
./check_mssql_uptime.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file

<pre>
OK - 4d 00:08:54
</pre>

## ./check_mssql_log_space_usage.pl 

./check_mssql_log_space_usage.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file --free --warning=90 --critical=80 --perfdata=1 --print-options=0

<pre>
CRITICAL | 1_used_log_space_in_bytes=687616,1_free_log_space_in_bytes=1663488,1_percent_free=70.753487;90;80;0;100
</pre>

 ./check_mssql_log_space_usage.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file --free --warning=90 --critical=80 --perfdata=0 --print-options=0
 
<pre>
CRITICAL
</pre>

./check_mssql_log_space_usage.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file --free --warning=90 --critical=80 --perfdata=1 --print-options=1

<pre>
CRITICAL | 1_used_log_space_in_bytes=687616,1_free_log_space_in_bytes=1663488,1_percent_free=70.753487;90;80;0;100

Options:

nagios-status => 2
db => master
hostname => 10.122.4.108
critical => 80
odbc-string => ODBC Driver 11 for SQL Server
free => 1
nagios-msg => CRITICAL
authfile => ../auth.file
port => 60900
username => monitor
warning => 90
perfdata => 1
print-options => 1
database_id => 1
        log_space_in_bytes_since_last_backup => 98304
        free_log_space_in_percent => 70.753487
        used_log_space_in_percent => 29.246515
        used_log_space_in_bytes => 687616
        total_log_size_in_bytes => 2351104
        free_log_space_in_bytes => 1663488
</pre>

## ./check_mssql_options.pl

./check_mssql_options.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file  --options="is_auto_create_stats_on:1,is_auto_update_stats_on:1"

<pre>
OK

OK - [is_auto_create_stats_on] == [1]
OK - [is_auto_update_stats_on] == [1]
</pre>

./check_mssql_options.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file  --options="is_auto_create_stats_on:1,is_auto_update_stats_on:1" -v

<pre>
$VAR1 = {
          'is_sync_with_backup' => '0',
          'recovery_model' => '3',
          'default_fulltext_language_name' => undef,
          'is_read_committed_snapshot_on' => '0',
          'snapshot_isolation_state' => '0',
          'is_in_standby' => '0',
          'is_quoted_identifier_on' => '0',
          'log_reuse_wait_desc' => 'NOTHING',
          'name' => 'ECM',
          'default_fulltext_language_lcid' => undef,
          'owner_sid' => '',
          'resource_pool_id' => undef,
          'is_numeric_roundabort_on' => '0',
          'is_local_cursor_default' => '0',
          'is_ansi_warnings_on' => '0',
          'is_ansi_null_default_on' => '0',
          'is_subscribed' => '0',
          'is_query_store_on' => '0',
          'is_honor_broker_priority_on' => '0',
          'is_trustworthy_on' => '0',
          'is_parameterization_forced' => '0',
          'two_digit_year_cutoff' => undef,
          'is_date_correlation_on' => '0',
          'is_recursive_triggers_on' => '0',
          'database_id' => 5,
          'is_nested_triggers_on' => undef,
          'is_read_only' => '0',
          'log_reuse_wait' => '0',
          'create_date' => '2016-08-19 12:12:34.370',
          'user_access' => '0',
          'is_auto_close_on' => '0',
          'delayed_durability' => 0,
          'is_memory_optimized_elevate_to_snapshot_on' => '0',
          'is_supplemental_logging_enabled' => '0',
          'is_concat_null_yields_null_on' => '0',
          'is_transform_noise_words_on' => undef,
          'is_auto_create_stats_on' => '1',
          'state' => '0',
          'page_verify_option_desc' => 'CHECKSUM',
          'is_cursor_close_on_commit_on' => '0',
          'service_broker_guid' => 'CD7E7ADE-EA68-48DF-86B9-BD610F23A78D',
          'user_access_desc' => 'MULTI_USER',
          'is_encrypted' => '0',
          'is_master_key_encrypted_by_server' => '0',
          'containment' => '0',
          'compatibility_level' => '120',
          'is_cleanly_shutdown' => '0',
          'is_arithabort_on' => '0',
          'source_database_id' => undef,
          'is_merge_published' => '0',
          'is_fulltext_enabled' => '1',
          'collation_name' => 'SQL_Latin1_General_CP850_BIN2',
          'is_auto_shrink_on' => '0',
          'page_verify_option' => '2',
          'is_auto_create_stats_incremental_on' => '0',
          'delayed_durability_desc' => 'DISABLED',
          'group_database_id' => undef,
          'is_broker_enabled' => '1',
          'state_desc' => 'ONLINE',
          'is_db_chaining_on' => '0',
          'is_auto_update_stats_on' => '1',
          'snapshot_isolation_state_desc' => 'OFF',
          'is_distributor' => '0',
          'is_ansi_padding_on' => '0',
          'is_auto_update_stats_async_on' => '1',
          'recovery_model_desc' => 'SIMPLE',
          'is_cdc_enabled' => '0',
          'default_language_lcid' => undef,
          'replica_id' => undef,
          'default_language_name' => undef,
          'containment_desc' => 'NONE',
          'is_ansi_nulls_on' => '1',
          'is_published' => '0',
          'target_recovery_time_in_seconds' => 0
        };
OK

OK - [is_auto_create_stats_on] == [1]
OK - [is_auto_update_stats_on] == [1]

</pre>

##  ./check_mssql_auto_file_growth.pl 

./check_mssql_auto_file_growth.pl --host='10.122.4.108' --db=master --port=60900 --auth=../auth.file

<pre>
OK

OK
        database_id       => 4
        db_name           => msdb
        file_id           => 1
        file_name         => MSDBData
        type_desc         => ROWS
        size              => 2416
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 4
        db_name           => msdb
        file_id           => 2
        file_name         => MSDBLog
        type_desc         => LOG
        size              => 2512
        max_size          => 268435456
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 1
        db_name           => master
        file_id           => 1
        file_name         => master
        type_desc         => ROWS
        size              => 688
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 1
        db_name           => master
        file_id           => 2
        file_name         => mastlog
        type_desc         => LOG
        size              => 288
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 3
        db_name           => model
        file_id           => 1
        file_name         => modeldev
        type_desc         => ROWS
        size              => 536
        max_size          => -1
        growth            => 128
        is_percent_growth => 0
OK
        database_id       => 3
        db_name           => model
        file_id           => 2
        file_name         => modellog
        type_desc         => LOG
        size              => 128
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 2
        db_name           => tempdb
        file_id           => 4
        file_name         => tempdev3
        type_desc         => ROWS
        size              => 12800
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 2
        db_name           => tempdb
        file_id           => 1
        file_name         => tempdev
        type_desc         => ROWS
        size              => 12800
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 2
        db_name           => tempdb
        file_id           => 3
        file_name         => tempdev2
        type_desc         => ROWS
        size              => 12800
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 2
        db_name           => tempdb
        file_id           => 2
        file_name         => templog
        type_desc         => LOG
        size              => 2560
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 2
        db_name           => tempdb
        file_id           => 5
        file_name         => tempdev4
        type_desc         => ROWS
        size              => 12800
        max_size          => -1
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 5
        db_name           => ECM
        file_id           => 4
        file_name         => ECMDATA3
        type_desc         => ROWS
        size              => 1661440
        max_size          => -1
        growth            => 7680
        is_percent_growth => 0
OK
        database_id       => 5
        db_name           => ECM
        file_id           => 1
        file_name         => ECMDATA1
        type_desc         => ROWS
        size              => 1661440
        max_size          => -1
        growth            => 7680
        is_percent_growth => 0
OK
        database_id       => 5
        db_name           => ECM
        file_id           => 3
        file_name         => ECMDATA2
        type_desc         => ROWS
        size              => 1661440
        max_size          => -1
        growth            => 7680
        is_percent_growth => 0
OK
        database_id       => 5
        db_name           => ECM
        file_id           => 2
        file_name         => ECMLOG1
        type_desc         => LOG
        size              => 271096
        max_size          => 268435456
        growth            => 10
        is_percent_growth => 1
OK
        database_id       => 5
        db_name           => ECM
        file_id           => 5
        file_name         => ECMDATA4
        type_desc         => ROWS
        size              => 1661440
        max_size          => -1
        growth            => 7680
        is_percent_growth => 0
</pre>
