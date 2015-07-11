# NAME

stricter - than strict. Fatalize stricter and misc warnings.

# SYNOPSIS

    use stricter;

    my (@a, $x) = (1, 2);
    => (W stricter)(F) Wrong slurpy assignment with @a in LIST, leaving $x as undef

    my %h = 0;
    => (W misc)(F) Odd number of elements in hash assignment ERROR

# DESCRIPTION

Adds stricter compile-time checks than strict, and fatalizes some compile-time
warnings from the **misc** category.

It adds a new warnings category **stricter**, and throws a warning
on the "Possibly" cases, in the non "Possibly" cases the warnings are **FATAL**.

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

The warnings can be **unfatalized** with

    use warnings 'NONFATAL' => 'stricter';

and **hidden** with:

    no warnings qw(stricter misc);

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
