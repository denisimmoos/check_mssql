#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_mssql_log_space_usage.pl
#
#        USAGE: ./check_mssql_log_space_usage.pl  
#
#  DESCRIPTION: Checks multiple mssql tablespaces
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
#      VERSION: 1.0
#      CREATED: 01/20/2016 09:26:28 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use POSIX qw{strftime};

#use lib '/usr/lib64/nagios/plugins/check_mssql/lib';
use lib '/home/monitor/check_mssql/lib';

#===============================================================================
# MODULES
#===============================================================================

use Module::Load;
use Data::Dumper;

#===============================================================================
# OPTIONS
#===============================================================================

my %Options = ();
$Options{'print-options'} = 1;
$Options{'odbc-string'} = 'ODBC Driver 11 for SQL Server';
$Options{'perfdata'} = 1;

#===============================================================================
# SYGNALS - to syslog
#===============================================================================

# You can get all SIGNALS by:
# perl -e 'foreach (keys %SIG) { print "$_\n" }'
# $SIG{'INT'} = 'DEFAULT';
# $SIG{'INT'} = 'IGNORE';

sub INT_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "INT: int($signal)\n";
    print $msg;
    syslog('info',$msg);
    exit(0);
}
$SIG{INT} = 'INT_handler';

sub DIE_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "DIE: die($signal)\n";
    print $msg;
    syslog('info',$msg);
}
$SIG{__DIE__} = 'DIE_handler';

sub WARN_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "WARN: warn($signal)\n";
    print $msg;
    syslog('info',$msg);
}
$SIG{__WARN__} = 'WARN_handler';

 
#===============================================================================
# Getopt::Long;
#===============================================================================



use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions(\%Options,
    'v',    'verbose',
    'h',    'help',
    'H:s',  'hostname:s',
    'A:s',  'authfile:s',
    'D:s',  'db:s',
    'P:i',  'port:i',
    'W:s',  'warning:s',
    'C:s',  'critical:s',
            'odbc-string:s',      #
            'perfdata:i',      #
            'print-options:i',      #
            'free',      #
            'used',      #
            'username:s',      #
            'password:s',      #
);

#===============================================================================
# PARSE OPTIONS
#===============================================================================

my $ParseOptions = 'MssqlLogSpaceUsage::ParseOptions';
load $ParseOptions;
$ParseOptions = $ParseOptions->new();
%Options = $ParseOptions->parse(\%Options);


#===============================================================================
# SQL
#===============================================================================

my $SQL = 'MssqlLogSpaceUsage::SQL';
load $SQL;
$SQL = $SQL->new();
%Options = $SQL->sql(\%Options);

#===============================================================================
# MAIN
#===============================================================================

#===============================================================================
# Nagios
#===============================================================================

my %NagiosStatus = (
    OK       => 0,
    WARNING  => 1,
    CRITICAL => 2,
    UNKNOWN  => 3,

    0       => 'OK',
    1       => 'WARNING',
    2       => 'CRITICAL',
    3       => 'UNKNOWN',
);

#
# defaults
#
$Options{'nagios-msg'} = $NagiosStatus{0};
$Options{'nagios-status'} = $NagiosStatus{'OK'};

#'log_space_in_bytes_since_last_backup' => '102912',
#'free_log_space_in_percent' => '72.60453',
#'used_log_space_in_percent' => '27.39547',
#'database_id' => 1,
#'used_log_space_in_bytes' => '644096',
#'total_log_size_in_bytes' => '2351104',
#'free_log_space_in_bytes' => '1707008'


my $perfdata;
foreach my $database_id (keys $Options{'MssqlLogSpaceUsage'} ){

	if ($Options{'used'}) {

		    if ( $Options{'MssqlLogSpaceUsage'}{$database_id}{'used_log_space_in_percent'} >= $Options{'warning'} ) {
				$Options{'nagios-msg'} = $NagiosStatus{1};
				$Options{'nagios-status'} = $NagiosStatus{'WARNING'};
			}  
		    if ( $Options{'MssqlLogSpaceUsage'}{$database_id}{'used_log_space_in_percent'} >= $Options{'critical'} ) {
				$Options{'nagios-msg'} = $NagiosStatus{2};
				$Options{'nagios-status'} = $NagiosStatus{'CRITICAL'};
			}  
                
			# performanc data
			$perfdata .= "${database_id}_used_log_space_in_bytes=$Options{'MssqlLogSpaceUsage'}{$database_id}{'used_log_space_in_bytes'},";
	        $perfdata .= "${database_id}_free_log_space_in_bytes=$Options{'MssqlLogSpaceUsage'}{$database_id}{'free_log_space_in_bytes'},";
			$perfdata .= "${database_id}_percent_used=$Options{'MssqlLogSpaceUsage'}{$database_id}{'used_log_space_in_percent'};$Options{'warning'};$Options{'critical'};0;100";

	
	}

	if ($Options{'free'}) {

		    if ( $Options{'MssqlLogSpaceUsage'}{$database_id}{'free_log_space_in_percent'} <= $Options{'warning'} ) {
				$Options{'nagios-msg'} = $NagiosStatus{1};
				$Options{'nagios-status'} = $NagiosStatus{'WARNING'};
			}  
		    if ( $Options{'MssqlLogSpaceUsage'}{$database_id}{'free_log_space_in_percent'} <= $Options{'critical'} ) {
				$Options{'nagios-msg'} = $NagiosStatus{2};
				$Options{'nagios-status'} = $NagiosStatus{'CRITICAL'};
			}  

	
			#performance data
			$perfdata .= "${database_id}_used_log_space_in_bytes=$Options{'MssqlLogSpaceUsage'}{$database_id}{'used_log_space_in_bytes'},";
	        $perfdata .= "${database_id}_free_log_space_in_bytes=$Options{'MssqlLogSpaceUsage'}{$database_id}{'free_log_space_in_bytes'},";
			$perfdata .= "${database_id}_percent_free=$Options{'MssqlLogSpaceUsage'}{$database_id}{'free_log_space_in_percent'};$Options{'warning'};$Options{'critical'};0;100";


	}

}

#
# output
#
my $out_perfdata ='';
if ( $Options{'perfdata'} ){
	$out_perfdata = "| $perfdata";
}

print "$Options{'nagios-msg'} $out_perfdata" . "\n";

if ($Options{'print-options'} ) {
        print "\n";
        print 'Options: ' ."\n\n";
        foreach my $option (keys(%Options)) {
               next if ( $option =~ /password/ );
               next if ( $option =~ /^[a-zA-Z]$/ );
			   if ( $option =~ /MssqlLogSpaceUsage/ ){

				foreach my $database_id (keys $Options{'MssqlLogSpaceUsage'} ) {
				   print "database_id => $database_id " . "\n";
				   foreach my $sub (keys $Options{'MssqlLogSpaceUsage'}{$database_id} ) {
					   next if ($sub =~ /database_id/);
					   print "\t$sub => $Options{'MssqlLogSpaceUsage'}{$database_id}{$sub}" . "\n";
				   }
				}
			    
			} else {
                   print "$option => $Options{$option}" . "\n";
			}
        }
}



exit($Options{'nagios-status'});

__END__

=head1 NAME

check_mssql_log_space_usage.pl 

=head1 SYNOPSIS

./check_mssql_log_space_usage.pl 

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

