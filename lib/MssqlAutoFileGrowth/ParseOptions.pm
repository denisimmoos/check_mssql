package MssqlAutoFileGrowth::ParseOptions;

#===============================================================================
#
#         FILE: ParseOptions.pm
#      PACKAGE: MssqlAutoFileGrowth::ParseOptions
#
#  DESCRIPTION: ParseOptions for MssqlAutoFileGrowth
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
#      VERSION: 1.0
#      CREATED: 11/22/2015 03:11:47 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
} 

sub error {
	my $caller = shift;
	my $msg = shift || $caller;
	die( "ERROR($caller): $msg" );
}

sub verbose {
	my $caller = shift;
	my $msg = shift || $caller;
	print( "INFO($caller): $msg" . "\n" );
}


sub parse {
	my $self = shift;
	my $ref_Options = shift;
	my %Options = %{ $ref_Options };
	my $caller = (caller(0))[3];


	foreach my $opt (keys(%Options)) {
					   
		next if ($opt =~ /print-options/ );
		next if ($opt =~ /only-critical/ );
		
		&error($caller,'$Options{' . $opt . '} not defined') if not ($Options{$opt}); 
	    &verbose($caller,'$Options{' . $opt . '} defined') if ( $Options{'v'} or $Options{'verbose'} ); 
	}

    # 
	# hostname
	#
	&error($caller,'$Options{hostname} must be defined') if not ( $Options{'H'} or $Options{'hostname'} ); 
	if ($Options{'H'}) { $Options{'hostname'} = $Options{'H'} };
	if ($Options{'hostname'}) { $Options{'H'} = $Options{'hostname'} };
	&verbose($caller,'$Options{hostname} = ' . $Options{'hostname'}  ) if ( $Options{'v'} or $Options{'verbose'} ); 

    # 
	# db
	#
	&error($caller,'$Options{db} must be defined') if not ( $Options{'D'} or $Options{'db'} ); 
	if ($Options{'D'}) { $Options{'db'} = $Options{'D'} };
	if ($Options{'db'}) { $Options{'D'} = $Options{'db'} };
	&verbose($caller,'$Options{db} = ' . $Options{'db'}  ) if ( $Options{'v'} or $Options{'verbose'} ); 

    # 
	# port
	#
	&error($caller,'$Options{port} must be defined') if not ( $Options{'P'} or $Options{'port'} ); 
	if ($Options{'P'}) { $Options{'port'} = $Options{'P'} };
	if ($Options{'port'}) { $Options{'P'} = $Options{'port'} };
	&verbose($caller,'$Options{port} = ' . $Options{'port'}  ) if ( $Options{'v'} or $Options{'verbose'} ); 
	
	#
	# authfile
	#
	if ( not ( $Options{'username'} and  $Options{'password'} )) {
	
		&error($caller,'$Options{authfile} must be defined') if not ($Options{'authfile'} or $Options{'A'} ); 
	    if ($Options{'A'}) { $Options{'authfile'} = $Options{'A'} };
	    if ($Options{'authfile'}) { $Options{'A'} = $Options{'authfile'} };
		&error($caller,'$Options{authfile} not a file') if not ( -f $Options{'authfile'} ); 
		&error($caller,'$Options{authfile} cannot be defined together with --username') if ( $Options{'username'} ); 
		&error($caller,'$Options{authfile} cannot be defined together with --password') if ( $Options{'password'} ); 
		&verbose($caller,'$Options{authfile} = ' . $Options{'authfile'}) if ( $Options{'v'} or $Options{'verbose'} ); 

		open(AUTHFILE,$Options{'authfile'}) or &error($caller,'open(' . $Options{authfile} .')');
		my @authfile;
		while (my $row = <AUTHFILE>) {
				chomp $row;
				push(@authfile,$row);
		}
		$Options{'username'} = $authfile[0];
		$Options{'password'} = $authfile[1];

		&error($caller,'$Options{authfile} format error') if ( scalar(@authfile) != 2 ); 
		close(AUTHFILE) or &error($caller,'close(' . $Options{authfile} .')');
	}

	#
	# username
	#
	&error($caller,'$Options{username} must be defined') if not ($Options{'username'} ); 
	&verbose($caller,'$Options{username} = ' . $Options{'username'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# password
	#
	&error($caller,'$Options{password} must be defined') if not ($Options{'password'} ); 
	&verbose($caller,'$Options{password} = ' . $Options{'password'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	return %Options;
}

1;

__END__

=head1 NAME

MssqlAutoFileGrowth::ParseOptions - ParseOptions for MssqlAutoFileGrowth 

=head1 SYNOPSIS

use MssqlAutoFileGrowth::ParseOptions;

my $object = MssqlAutoFileGrowth::ParseOptions->new();

my %HASH = $object->parse(\%HASH);

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>,
Senior Linux System Administrator (LPIC3)

=cut


