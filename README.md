# check_mssql
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
