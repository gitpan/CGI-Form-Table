
package CGI::Form::Table;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

CGI::Form::Table - create a table of form inputs

=head1 VERSION 

version 0.01

 $Id: Table.pm,v 1.2 2004/10/04 19:43:33 rjbs Exp $

=head1 SYNOPSIS

 use CGI::Form::Table;

 my $form = CGI::Form::Table->new(columns => [qw(lname fname job age)]);

 print $form->as_html;

=head1 DESCRIPTION

This module simplifies the creation of an HTML table containing form inputs.
The table can be extended to include extra rows, and these rows can be removed.
Each has a unique name, and on form submission the inputs are effectively
serialized.

L<CGI::Form::Table::Reader> will use the CGI module to produce a data structure
based on the parameters submitted by a form of this type.

=head1 METHODS

=head2 C<< CGI::Form::Table->new(%arg) >>

This method constructs a new form.  The only required arguments  are
C<columns>, which names the columns that will be in the form table, and
C<prefix>, which gives the unique prefix for input fields.

If given, C<initial_rows> specifies how many rows should initially be in the
form.

=cut

sub new {
	my ($class, %arg) = @_;
	return unless $arg{columns};
	return unless $arg{prefix};
	$arg{initial_rows} = 1 unless $arg{initial_rows};
	bless \%arg => $class;
}

=head2 C<< CGI::Form::Table->as_html >>

This returns HTML representing the form object.  JavaScript is included to make
the form expandible/shrinkable.  (L</"SEE ALSO">)

=cut

sub as_html {
	my ($self) = @_;

	my $html = "<table>\n";

	$html .= "\t<tr>";
	$html .= "<td></td><td></td>";
	$html .= "<th>$_</th>" for @{$self->{columns}};
	$html .= "</tr>\n";

	for my $row_number (1 .. $self->{initial_rows}) {
		$html .= "\t<tr>";
		$html .= "<td><input type='button' onClick='cloneParentOf(this.parentNode)' value='+' /></td>";
		$html .= "<td><input type='button' onClick='removeParentOf(this.parentNode)' value='-' /></td>";
		$html .= "<td><input name='$self->{prefix}_${row_number}_$_' /></td>"
			for @{$self->{columns}};
		$html .= "</tr>\n";
	}
	$html .= "</table>\n";
	$html .= "<script type='text/javascript'>" . $self->javascript . "</script>";

	return $html;
}

=head2 javascript

This method returns JavaScript that will make the handlers for the HTML buttons
work.  Currently this code is known to work in MSIE and Firefox, but not Safari
or Omniweb.  (Patches welcome.)

=cut

sub javascript {
	my $self = shift;
	my $prefix = $self->{prefix};
return <<"EOS";
	function removeParentOf(child) {
		tbody = child.parentNode.parentNode;
		if (tbody.rows.length > 1)
			tbody.removeChild(child.parentNode);
		renumberRows(tbody);
	}
	function cloneParentOf(child) {
		clone = child.parentNode.cloneNode( true );
		tbody = child.parentNode.parentNode;
		tbody.insertBefore( clone, child.parentNode );
		renumberRows(tbody);
	}
	function renumberRows(tbody) {
		var rowList = tbody.rows;
		for (i = 0; i < rowList.length; i++) {
			rowNumber = rowList.length - i;
			rowList.item(i).cells.item(0).firstChild.nodeValue = rowNumber;
			for (j = 0; j < rowList.item(i).cells.length; j++) {
				inputs = rowList.item(i).cells.item(j).getElementsByTagName('input');
				for (k = 0; k < inputs.length; k++) {
					if (inputs[k].name.match(/^${prefix}_\\d+_/))
						inputs[k].name = inputs[k].name.replace(/^${prefix}_\\d+_/, rowNumber + "_");
				}
			}
			var cell_count = rowList.item(i).cells.length;
			rowList.item(i).cells.item(cell_count - 1).firstChild.nodeValue = rowNumber;
		}
	}
EOS

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
