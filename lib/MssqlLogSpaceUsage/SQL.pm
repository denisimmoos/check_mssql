package MssqlLogSpaceUsage::SQL;

#===============================================================================
#
#         FILE: SQL.pm
#      PACKAGE: SQL
#
#  DESCRIPTION: SQL MssqlLogSpaceUsage
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
#      VERSION: 1.0
#      CREATED: 01/27/2016 01:03:34 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use DBI;

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


sub sql {

    my $self = shift;
    my $ref_Options = shift;
    my %Options = %{ $ref_Options };
    my $caller = (caller(0))[3];

	#use Data::Dumper;

	my $sql_databases = "
		SELECT 
		[master].[sys].[databases].name
		FROM [$Options{'db'}].[sys].[databases]
	";

	if ($Options{'exclude-db'}) {
		my @exclude = split(/\,/,$Options{'exclude-db'});
		my $exclude = join ',', map qq('$_'), @exclude;
		$sql_databases .= "WHERE [master].[sys].[databases].name NOT IN ( $exclude )";
	}
				
	my $sql;
	my $sth;


	my $dbh = DBI->connect("dbi:ODBC:driver=$Options{'odbc-string'};server=tcp:$Options{'hostname'},$Options{'port'};database=$Options{'db'};MARS_Connection=yes;", $Options{'username'}, $Options{'password'} )
    	or die( $DBI::errstr . "\n");

    	my $sth_databases = $dbh->prepare($sql_databases);
       	$sth_databases->execute;

	while ( my $row = $sth_databases->fetchrow_hashref ) {

		
		$sql = "
		       SELECT 
			   [database_id]
			  ,[total_log_size_in_bytes]
			  ,[used_log_space_in_bytes]
			  ,([total_log_size_in_bytes] - [used_log_space_in_bytes]) AS free_log_space_in_bytes
			  ,[used_log_space_in_percent]
			  ,(100-[used_log_space_in_percent]) AS free_log_space_in_percent
			  ,[log_space_in_bytes_since_last_backup]
			  FROM [$row->{'name'}].[sys].[dm_db_log_space_usage]
		";
		
    		$sth = $dbh->prepare($sql);
       		$sth->execute;

		while ( my $sub_row = $sth->fetchrow_hashref ) {
			$Options{'MssqlLogSpaceUsage'}{$row->{'name'}} = $sub_row
		}
		
	}

	return  %Options;

}

1;

__END__

=head1 NAME

SQL - SQL MssqlLogSpaceUsage 

=head1 SYNOPSIS

use SQL;

my $object = SQL->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

=cut


