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

