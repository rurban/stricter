package stricter;

use 5.006;
use strict;
our $VERSION = '0.01';
use XSLoader ();
use Carp ();
use warnings ();
use warnings::register;

sub import {
    $^H |= 0x7e2; # use strict
    $^W = 1;      # use warnings
    warnings->import('FATAL' => qw(misc stricter));
}

XSLoader::load;
1;
__END__

=head1 NAME

stricter - than strict. Fatalize stricter and misc warnings.

=head1 SYNOPSIS

  use stricter;

  my (@a, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x uninitialized

  my %h = 0;
  => (W misc)(F) Odd number of elements in hash assignment ERROR


=head1 DESCRIPTION

use stricter adds stricter compile-time checks than strict, enables
the default warnings and fatalizes the compile-time warnings from this
B<stricter> and the B<misc> category.

    use stricter;

might be a better replacement for the typical idiom:

    use strict;
    use warnings;

or L<common::sense>, which is similar but has a misleading name.

stricter adds a new warnings category B<stricter>, and throws a warning
on the "Possibly" cases. In the non "Possibly" cases the warnings are B<FATAL>.

When the left-hand side of an list assignment contains an ARRAY or HASH
not as last element.

  my (@a, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x uninitialized

  my (%h, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with %h in LIST, leaving $x uninitialized

When the left-hand side of an list assignment contains not enough elements,
and the right-hand side is a not-empty list it displays a non fatal warning.

  my ($a, $b, $c) = (1, 2);
  => (W stricter) Possibly missing assignment to $c in LIST, leaving $c uninitialized

When the right-hand side of an assignment to a HASH contains an uneven
number of elements, it fatalizes the 'misc' warning.

  my (%h) = (0);
  => (W misc)(F) Odd number of elements in hash assignment

The warnings can be B<unfatalized> with

    use warnings 'NONFATAL' => 'stricter';

or B<hidden> with:

    no warnings qw(stricter misc);

Note:

All those errors are perfectly legal perl syntax, and used quite often in
legacy code. But errors from overseeing such missing initializations are hard
to detect, and should not be allowed in this stricter mode.

=head2 Better error diagnostics

Unlike most perl 5 errors and warnings C<stricter> prints the wrong
variable name, not only the type.

=head1 SEE ALSO

L<strict>, L<warnings>, L<perldiag>

=head1 AUTHOR

Reini Urban, E<lt>rurban@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by cPanel Inc

This library is free software; you can redistribute it and/or modify
it under the terms of the Artistic License 2.0.

=cut
