use Test::More tests => 7;

use strict;
use warnings;

use_ok( 'CGI::Form::Table' );

{
	my $form = CGI::Form::Table->new(
		prefix  => 'whatever',
		columns => [qw(profile xmole dopeconc thick dopant)]
	);

	ok($form->as_html,    "got some output");
	ok($form->javascript, "got some output");
}

{
	my $form = CGI::Form::Table->new(
		prefix  => 'whatever',
		columns => [qw(profile xmole dopeconc thick dopant)],
		initial_rows => 10
	);

	ok($form->as_html,    "got some output");
	ok($form->javascript, "got some output");
}

{
	my $form = CGI::Form::Table->new(
		prefix  => 'whatever',
		columns => [qw(profile xmole dopeconc thick dopant)],
		column_content => {
			xmole  => sub { 'disabled' },
			dopant => CGI::Form::Table->_select([ A => 'Alpha' ], [B => 'Beta' ])
		}
	);

	ok($form->as_html,    "got some output");
	ok($form->javascript, "got some output");
}
