# NAME

stricter - than strict. Fatalize stricter and misc warnings.

# SYNOPSIS

    use stricter;

    my (@a, $x) = (1, 2);
    => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x uninitialized

    my %h = 0;
    => (W misc)(F) Odd number of elements in hash assignment ERROR

# DESCRIPTION

use stricter adds stricter compile-time checks than strict, enables
the default warnings and fatalizes the compile-time warnings from this
**stricter** and the **misc** category.

    use stricter;

might be a better replacement for the typical idiom:

    use strict;
    use warnings;

or [common::sense](https://metacpan.org/pod/common::sense), which is similar but has a misleading name.

stricter adds a new warnings category **stricter**, and throws a warning
on the "Possibly" cases. In the non "Possibly" cases the warnings are **FATAL**.

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

The warnings can be **unfatalized** with

    use warnings 'NONFATAL' => 'stricter';

or **hidden** with:

    no warnings qw(stricter misc);

Note:

All those errors are perfectly legal perl syntax, and used quite often in
legacy code. But errors from overseeing such missing initializations are hard
to detect, and should not be allowed in this stricter mode.

## Better error diagnostics

Unlike most perl 5 errors and warnings `stricter` prints the wrong
variable name, not only the type.

# SEE ALSO

[strict](https://metacpan.org/pod/strict), [warnings](https://metacpan.org/pod/warnings), [perldiag](https://metacpan.org/pod/perldiag)

# AUTHOR

Reini Urban, <rurban@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2015 by cPanel Inc

This library is free software; you can redistribute it and/or modify
it under the terms of the Artistic License 2.0.
