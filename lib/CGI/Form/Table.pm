
package CGI::Form::Table;

use strict;
use warnings;

our $VERSION = '0.00';

=head1 NAME

CGI::Form::Table - create a table of form inputs

=head1 VERSION 

version 0.00

 $Id: Table.pm,v 1.1.1.1 2004/10/04 17:54:06 rjbs Exp $

=head1 SYNOPSIS

 use CGI::Form::Table;

 my $form = CGI::Form::Table->new(columns => [qw(lname fname job age)]);

 print $form->as_html;
 print $form->javascript;

=head1 DESCRIPTION

B<THIS CODE IS UNWRITTEN>

This module will be implemented, but hasn't been quite yet.  It's other half,
L<CGI::Form::Table::Reader>, which parses the input create by forms created by
this module, does exist and work.  Funny, that.

This module simplifies the creation of an HTML table containing form inputs.
The table can be extended to include extra rows, and these rows can be removed.
Each has a unique name, and on form submission the inputs are effectively
serialized.

=head1 METHODS

=head2 C<< CGI::Form::Table::Reader->new(%arg) >>

This method constructs a new form.  The only definitely planned argument is
C<columns>, which names the columns that will be in the form table.

=cut

sub new {
}

=head2 C<< CGI::Form::Table::Reader->as_html >>

This returns HTML representing the form object.  JavaScript exists to make the
form expandible/shrinkable.  (L</"SEE ALSO">)

=cut

sub as_html {
}

=head1 SEE ALSO

=over 4

=item * L<http://rjbs.manxome.org/hacks/js/plusminus.html>

=item * L<CGI::Form::Table::Reader>

=back

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2004 Ricardo SIGNES, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
