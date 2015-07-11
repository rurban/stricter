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
    warnings->import('FATAL' => 'misc');
    warnings->import('FATAL' => 'stricter');
}

XSLoader::load;
1;
__END__

=head1 NAME

stricter - than strict. Fatalize stricter and misc warnings.

=head1 SYNOPSIS

  use stricter;

  my (@a, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x as undef

  my %h = 0;
  => (W misc)(F) Odd number of elements in hash assignment ERROR


=head1 DESCRIPTION

Adds stricter compile-time checks than strict, and fatalizes some compile-time
warnings from the B<misc> category.

It adds a new warnings category B<stricter>, and throws a warning
on the "Possibly" cases, in the non "Possibly" cases the warnings are B<FATAL>.

When the left-hand side of an list assignment contains an ARRAY or HASH
not as last element.

  my (@a, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x as undef

  my (%h, $x) = (1, 2);
  => (W stricter)(F) Wrong slurpy assignment with %h in LIST, leaving $x as undef

When the left-hand side of an list assignment contains not enough elements,
and the right-hand side is a not-empty list.

  my ($a, $b, $c) = (1, 2);
  => (W stricter) Possibly missing assignment to $c in LIST, leaving $c as undef

When the right-hand side of an assignment to a HASH contains an uneven
number of elements, it fatalizes the 'misc' warnings.

  my (%h) = (0);
  => (W misc)(F) Odd number of elements in hash assignment

The warnings can be B<unfatalized> with

    use warnings 'NONFATAL' => 'stricter';

and B<hidden> with:

    no warnings qw(stricter misc);

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
