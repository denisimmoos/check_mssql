#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_mssql_uptime.pl
#
#        USAGE: ./check_mssql_uptime.pl  
#
#  DESCRIPTION: Checks mssql uptime
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
#      VERSION: 1.0
#      CREATED: 09/29/2016 
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use POSIX qw{strftime};

use lib '/opt/contrib/plugins/check_mssql/lib';

#===============================================================================
# MODULES
#===============================================================================

use Module::Load;
use Data::Dumper;

#===============================================================================
# OPTIONS
#===============================================================================

my %Options = ();
$Options{'odbc-string'} = 'ODBC Driver 11 for SQL Server';
$Options{'timezone'} = 'Europe/Zurich';

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
    'C:s',  'critical:s',
            'odbc-string:s',      #
            'timezone:s',      #
            'username:s',      #
            'password:s',      #
);

#===============================================================================
# PARSE OPTIONS
#===============================================================================

my $ParseOptions = 'MssqlUptime::ParseOptions';
load $ParseOptions;
$ParseOptions = $ParseOptions->new();
%Options = $ParseOptions->parse(\%Options);


#===============================================================================
# SQL
#===============================================================================

my $SQL = 'MssqlUptime::SQL';
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



use DateTime;

use integer;
my $dt_NOW = DateTime->now();
   $dt_NOW->set_time_zone( $Options{'timezone'} );

   # datum aufsplitten
   #'sqlserver_start_time' => '2016-09-24 09:54:00.247'

   my @date_string = split(/[- :.]/,$Options{'MssqlUptime'}{'sqlserver_start_time'});


   # 0 -> 2016
   # 1 -> 09
   # 2 -> 24
   # 3 -> 09
   # 4 -> 54
   # 5 -> 00

   # replace 0
   $date_string[0] =~ s/^0//g;
   $date_string[1] =~ s/^0//g;
   $date_string[2] =~ s/^0//g;
   $date_string[3] =~ s/^0//g;
   $date_string[4] =~ s/^0//g;
   $date_string[5] =~ s/^0//g;

   my $dt_THEN =  DateTime->new( 
  	   year       => int($date_string[0]),
       month      => int($date_string[1]),
	   day        => int($date_string[2]),
	   hour       => int($date_string[3]),
	   minute     => int($date_string[4]),
	   second     => int($date_string[5]),
   );

   $dt_THEN->set_time_zone( $Options{'timezone'} );

   my $dt_duration = $dt_NOW->subtract_datetime_absolute($dt_THEN);

   sub dhms
   {
	   my $s = shift;
	   my $d = int($s/86400);
	   $s -= $d*86400;
	   my $h = int($s/3600);
	   $s -= $h*3600;
	   my $m = int($s/60);
	   $s -= $m*60;
	   return ($d,$h,$m,$s);
   }

   $dt_duration = sprintf "%dd %02d:%02d:%02d",&dhms($dt_duration->seconds);

print "$Options{'nagios-msg'} - $dt_duration" . "\n";
exit($Options{'nagios-status'});

__END__

=head1 NAME

check_mssql_uptime.pl 

=head1 SYNOPSIS

./check_mssql_uptime.pl 

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

