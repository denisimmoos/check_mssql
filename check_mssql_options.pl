#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_mssql_options.pl
#
#        USAGE: ./check_mssql_options.pl  
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
$Options{'print-options'} = 0;
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
    'C:s',  'options:s',
            'odbc-string:s',      #
            'print-options:i',      #
            'username:s',      #
            'password:s',      #
);

#===============================================================================
# PARSE OPTIONS
#===============================================================================

my $ParseOptions = 'MssqlOptions::ParseOptions';
load $ParseOptions;
$ParseOptions = $ParseOptions->new();
%Options = $ParseOptions->parse(\%Options);


#===============================================================================
# SQL
#===============================================================================

my $SQL = 'MssqlOptions::SQL';
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

my @Options= split(/,/,$Options{'options'});
my $key;
my $value;
my @CRITICAL = ();

foreach my $option (@Options) {


	($key,$value)= split(/\:/,$option);

	if ( not exists( $Options{'MssqlOptions'}{$key}) ){
		$Options{'nagios-msg'} = $NagiosStatus{2} . " - [$key] not valid";
		$Options{'nagios-status'} = $NagiosStatus{'CRITICAL'};
		die "$Options{'nagios-msg'}" . "\n";
	}

	if ( $Options{'MssqlOptions'}{$key} ne $value ) {
		push(@CRITICAL,1);
		$Options{'nagios-msg'} .= "\n" . $NagiosStatus{2} . " - [$key] != [$value]";
	} else {
		$Options{'nagios-msg'} .= "\n" . $NagiosStatus{0} . " - [$key] == [$value]";
	}	

}

#
# output
#

if(@CRITICAL) {
    print "CRITICAL\n" . $Options{'nagios-msg'} . "\n";
	$Options{'nagios-status'} = $NagiosStatus{'CRITICAL'};
} else {
    print "OK\n" . $Options{'nagios-msg'} . "\n";
	$Options{'nagios-status'} = $NagiosStatus{'OK'};
}

if ($Options{'print-options'} ) {
        print "\n\n";
        print 'Options: ' ."\n\n";
        foreach my $option (keys(%Options)) {
               next if ( $option =~ /password/ );
               next if ( $option =~ /^[a-zA-Z]$/ );

               if ( $option =~ /MssqlOptions/ ){
                   foreach my $sub (keys $Options{'MssqlOptions'} ) {
					   if($Options{'MssqlOptions'}{$sub}) {
                          print "$sub => $Options{'MssqlOptions'}{$sub}" . "\n";
					   
					   } else {
                          print "$sub =>  undef" . "\n";
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

check_mssql_options.pl 

=head1 SYNOPSIS

./check_mssql_options.pl 

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

