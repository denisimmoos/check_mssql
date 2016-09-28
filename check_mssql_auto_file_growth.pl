#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_mssql_auto_file_growth.pl
#
#        USAGE: ./check_mssql_auto_file_growth.pl  
#
#  DESCRIPTION: Checks in mssql if auto_file_growth is enabled 
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
$Options{'print-options'} = 0;
$Options{'only-critical'} = 0;
$Options{'odbc-string'} = 'ODBC Driver 11 for SQL Server';

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
            'odbc-string:s',      #
            'print-options:i',      #
            'only-critical:i',      #
            'username:s',      #
            'password:s',      #
);

#===============================================================================
# PARSE OPTIONS
#===============================================================================

my $ParseOptions = 'MssqlAutoFileGrowth::ParseOptions';
load $ParseOptions;
$ParseOptions = $ParseOptions->new();
%Options = $ParseOptions->parse(\%Options);


#===============================================================================
# SQL
#===============================================================================

my $SQL = 'MssqlAutoFileGrowth::SQL';
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

my @CRITICAL;
my $msg;
my $status;


foreach my $db (keys $Options{MssqlAutoFileGrowth}) {
  foreach my $file (keys $Options{MssqlAutoFileGrowth}{$db}) {
       
	   # default
	   $msg = $NagiosStatus{0};

	   # Bei type_desc = LOG: max_size = -1 oder max_size = 268435456

	   if ( $Options{MssqlAutoFileGrowth}{$db}{$file}{'type_desc'} eq 'LOG' ) {
		   if ( not (
			        ($Options{MssqlAutoFileGrowth}{$db}{$file}{'max_size'} eq '-1') or ($Options{MssqlAutoFileGrowth}{$db}{$file}{'max_size'} eq '268435456')
		       )
		   ) {
			   push(@CRITICAL,1);
			   $msg = $NagiosStatus{2};
		   }
	   } 
	   
	   # Bei type_desc = ROWS: max_size = -1
	   if ( $Options{MssqlAutoFileGrowth}{$db}{$file}{'type_desc'} eq 'ROWS' ) {

		   if ($Options{MssqlAutoFileGrowth}{$db}{$file}{'max_size'} ne '-1') {
			   push(@CRITICAL,1);
			   $msg = $NagiosStatus{2};

		   }

	   } 

	   # 
	   # message
	   #
	   if ( $msg eq 'OK'  and $Options{'only-critical'} ) {
		   $Options{'nagios-msg'} .= "";
	   } else {
		   $Options{'nagios-msg'} .= "\n" . $msg . " ";
		   $Options{'nagios-msg'} .= "\n\t" . "database_id       => $Options{MssqlAutoFileGrowth}{$db}{$file}{'database_id'}";
		   $Options{'nagios-msg'} .= "\n\t" . "db_name           => $Options{MssqlAutoFileGrowth}{$db}{$file}{'db_name'}";
		   $Options{'nagios-msg'} .= "\n\t" . "file_id           => $Options{MssqlAutoFileGrowth}{$db}{$file}{'file_id'}";
		   $Options{'nagios-msg'} .= "\n\t" . "file_name         => $Options{MssqlAutoFileGrowth}{$db}{$file}{'file_name'}";
		   $Options{'nagios-msg'} .= "\n\t" . "type_desc         => $Options{MssqlAutoFileGrowth}{$db}{$file}{'type_desc'}";
		   $Options{'nagios-msg'} .= "\n\t" . "size              => $Options{MssqlAutoFileGrowth}{$db}{$file}{'size'}";
		   $Options{'nagios-msg'} .= "\n\t" . "max_size          => $Options{MssqlAutoFileGrowth}{$db}{$file}{'max_size'}";
		   $Options{'nagios-msg'} .= "\n\t" . "growth            => $Options{MssqlAutoFileGrowth}{$db}{$file}{'growth'}";
		   $Options{'nagios-msg'} .= "\n\t" . "is_percent_growth => $Options{MssqlAutoFileGrowth}{$db}{$file}{'is_percent_growth'}";
	   }

  }
}

#
# output
#

if(@CRITICAL) {
    print "CRITICAL\n" . $Options{'nagios-msg'} . "\n";
	$Options{'nagios-status'} = $NagiosStatus{'CRITICAL'};
} else {
    print "OK" . $Options{'nagios-msg'} . "\n";
	$Options{'nagios-status'} = $NagiosStatus{'OK'};
}

if ($Options{'print-options'} ) {
        print "\n\n";
        print 'Options: ' ."\n\n";
        foreach my $option (keys(%Options)) {
               next if ( $option =~ /password/ );
               next if ( $option =~ /^[a-zA-Z]$/ );

               if ( $option =~ /MssqlAutoFileGrowth/ ){
                   foreach my $sub (keys $Options{'MssqlAutoFileGrowth'} ) {
					   if($Options{'MssqlAutoFileGrowth'}{$sub}) {
                          print "$sub => $Options{'MssqlAutoFileGrowth'}{$sub}" . "\n";
					   
					   } else {
                          print "$sub =>  undef" . "\n";
					   }
				   }
               } else {
                   print "$option => $Options{$option}" . "\n";
               }
        }
}

# exit
exit($Options{'nagios-status'});

__END__

=head1 NAME

check_mssql_auto_file_growth.pl 

=head1 SYNOPSIS

./check_mssql_auto_file_growth.pl 

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

