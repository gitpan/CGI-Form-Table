
package CGI::Form::Table;

use strict;
use warnings;

our $VERSION = '0.09';

=head1 NAME

CGI::Form::Table - create a table of form inputs

=head1 VERSION 

version 0.09

 $Id: Table.pm,v 1.8 2004/10/19 23:56:54 rjbs Exp $

=head1 SYNOPSIS

 use CGI::Form::Table;

 my $form = CGI::Form::Table->new(
   prefix  => 'employee',
   columns => [qw(lname fname job age)]
 );

 print $form->as_html;
 print $form->javascript;

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

Another argument, C<column_content>, may be passed.  It must contain a hashref,
with entries providing subs to produce initial content.  The subs are passed the
form object, the row number, and the name of the column.  For example, to add a
reminder of the current row in the middle of each row, you might create a form
like this:

 my $form = CGI::Form::Table->new(
   prefix  => 'simpleform',
   columns => [qw(one two reminder three four)],
   column_content => {
     reminder => sub { $_[1] }
   }
 );

This can be useful for forms that require SELECT elements or other complicated
parts.  (The JavaScript will just copy the column value when new rows are added,
updating the name attribute.)

=cut

sub new {
	my ($class, %arg) = @_;
	return unless $arg{columns};
	return unless $arg{prefix};
	$arg{initial_rows} = 1 unless $arg{initial_rows};
	bless \%arg => $class;
}

=head2 C<< CGI::Form::Table->as_html >>

This returns HTML representing the form object.  JavaScript is required to make
the form expandible/shrinkable; see the C<javascript> method.  (L</"SEE ALSO">)

=cut

sub _header {
	my ($self, $name) = @_;
	$self->{column_header}{$name} || $name;
}

sub _content {
	my ($self, $row, $name) = @_;

	my $content_generator =
		$self->{column_content}{$name}
		? $self->{column_content}{$name}
		: $self->_input;
	return $content_generator->($self, $row, $name);
}

# given a list of two-element arrayrefs, return a coderef to produce a select
# element via column_content
sub _select {
	my ($self, @pairs) = @_;
	sub {
		my ($self, $row, $name) = @_;
		my $content = "<select name='$self->{prefix}_${row}_$name'>";
		$content .= "<option value='$_->[0]'>$_->[1]</option>\n" for @pairs;
		$content .= "</select>\n";
		return $content;
	}
}

sub _input {
	sub {
		my ($self, $row, $name) = @_;
		return "<input name='$self->{prefix}_${row}_$name' />";
	}
}

sub as_html {
	my ($self) = @_;
	my $prefix = $self->{prefix};

	my $html = "<table>\n";

	$html .= "\t<thead>\n";
	$html .= "\t\t<tr>";
	$html .= "<td></td>"; # header for row number
	$html .= "<td></td><td></td>"; # header for +/-
	$html .= "<th>$_</th>" for map { $self->_header($_) } @{$self->{columns}};
	$html .= "<td></td>"; # header for row number
	$html .= "</tr>\n";
	$html .= "\t</thead>\n";

	$html .= "\t<tbody>\n";
	for my $row_number (1 .. $self->{initial_rows}) {
		my $content = join '', map
			{ "<td>" . $self->_content($row_number, $_) . "</td>" }
			@{$self->{columns}};
		$html .= <<EOT;
		<tr>
			<td>$row_number</td>
		  <td><input type='button' onClick='cloneParentOf(this.parentNode, "$prefix")' value='+' /></td>
			<td><input type='button' onClick='removeParentOf(this.parentNode, "$prefix")' value='-' /></td>
			$content
			<td>$row_number</td>
		</tr>
EOT
	}
	$html .= "\t</tbody>\n";
	$html .= "</table>\n";

	return $html;
}

=head2 javascript

This method returns JavaScript that will make the handlers for the HTML buttons
work.  This code has been (poorly) tested in Firefox, MSIE, and WebKit-based
browsers.

=cut

sub javascript {
	my $self = shift;
return <<"EOS";
	function removeParentOf(child, prefix) {
		tbody = child.parentNode.parentNode;
		if (tbody.rows.length > 1)
			tbody.removeChild(child.parentNode);
		renumberRows(tbody, prefix);
	}
	function cloneParentOf(child, prefix) {
		clone = child.parentNode.cloneNode( true );
		tbody = child.parentNode.parentNode;
		tbody.insertBefore( clone, child.parentNode );
		renumberRows(tbody, prefix);
	}
	function renumberRows(tbody, prefix) {
		var rowList = tbody.rows;
		for (i = 0; i < rowList.length; i++) {
			rowNumber = rowList.length - i;
			rowList.item(i).cells.item(0).firstChild.nodeValue = rowNumber;
			for (j = 0; j < rowList.item(i).cells.length; j++) {
				inputs = rowList.item(i).cells.item(j).getElementsByTagName('input');
				prefix_pattern = new RegExp('^' + prefix + '_\\d+_');
				for (k = 0; k < inputs.length; k++) {
					if (inputs[k].name.match(prefix_pattern))
						inputs[k].name = inputs[k].name.replace(prefix_pattern, prefix + "_" + rowNumber + "_");
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