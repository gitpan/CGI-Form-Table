use Test::More 'no_plan';

use strict;
use warnings;

use CGI;
BEGIN { use_ok("CGI::Form::Table::Reader"); }

is(
	CGI::Form::Table::Reader->new(),
	undef,
	"missing both params"
);

is(
	CGI::Form::Table::Reader->new(query => 1),
	undef,
	"missing prefix param"
);

is(
	CGI::Form::Table::Reader->new(prefix => 1),
	undef,
	"missing query param"
);

{
	my $query = CGI->new;

	is(
		CGI::Form::Table::Reader->new(prefix => 'foo', query => $query)->rows,
		undef,
		"no rows, because no positions"
	);
}

