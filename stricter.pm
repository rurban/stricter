package stricter;

use 5.006;
use strict;
our $VERSION = '0.01';
use XSLoader ();
use Carp ();
use warnings (); # load it
use warnings::register;
use multidimensional (); # load it

sub import {
    $^H |= 0x7e2; # use strict
    $^W = 1;      # use warnings
    warnings->import('FATAL' => qw(stricter misc deprecated)); # enable it
    multidimensional->unimport(); # enable it
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
the default warnings, enables no multidimensional and fatalizes the
compile-time warnings from this B<stricter> and the B<misc> and B<deprecated>
category.

    use stricter;

might be a better replacement for the typical idiom:

    use strict;
    use warnings;

    # plus
    no multidimensional;
    use warnings 'FATAL' => qw(misc deprecated);

L<common::sense> or L<strictures> are similar but have misleading or bad names, and
do not catch wrong slurpy assignments.

stricter adds a new warnings category B<stricter>, and throws a warning
on the I<"Possibly"> cases. In the non I<"Possibly"> cases the warnings are B<FATAL>.

=head2 Wrong slurpy assignment

When the left-hand side of an list assignment contains an ARRAY or HASH
not as last element.

  my (@a, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x uninitialized

  my (%h, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with %h in LIST, leaving $x uninitialized

=head2 Possibly missing assignment

When the left-hand side of an list assignment contains not enough elements,
and the right-hand side is a not-empty list it displays a non fatal warning.

  my ($a, $b, $c) = (1, 2);
  => (W stricter) Possibly missing assignment to $c in LIST, leaving $c uninitialized

=head2 Odd number of elements in hash assignment

When the right-hand side of an assignment to a HASH contains an uneven
number of elements, it fatalizes the 'misc' warning.

  my (%h) = (0);
  => (W misc)(F) Odd number of elements in hash assignment

=head2 Use of multidimensional array emulation

no L<multidimensional> makes using multidimensional array emulation a
fatal error at compile time. It is mostly confused with C<@hash{}> vs C<$hash{}>.

  $hash{1, 2};                # (F) Use of multidimensional array emulation
  $hash{join($;, 1, 2)};      # doesn't die

=head2 Relax errors to warnings

The warnings can be B<unfatalized> with

    use warnings 'NONFATAL' => 'stricter';

or B<hidden> with:

    no warnings qw(stricter misc);

=head2 Legacy note

All those errors are perfectly legal perl syntax, and used quite often
in legacy code. But errors from overseeing such missing
initializations are hard to detect, and should not be allowed in this
stricter mode.

=head2 Better error diagnostics

Unlike most perl 5 errors and warnings C<stricter> prints the wrong
variable name, not only the type.

=head1 SEE ALSO

L<strict>, L<warnings>, L<perldiag>, L<common::sense>, L<strictures>

=head1 AUTHOR

Reini Urban, E<lt>rurban@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by cPanel Inc

This library is free software; you can redistribute it and/or modify
it under the terms of the Artistic License 2.0.

=cut
