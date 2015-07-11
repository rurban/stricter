# -*- mode:perl perl-indent-level:4 -*-
use Test::More tests => 7;
BEGIN { use_ok('stricter') };

my ($w, $d);
local $SIG{__WARN__} = sub { $w = $_[0] };
local $SIG{__DIE__}  = sub { $d = $_[0] };

{
    eval "my (\@a, \$x) = (0, 1);";
    like($d, qr/^Wrong slurpy assignment with \@a in LIST, leaving \$x as undef/,
         "fatal");
    ok(!$w, 'no warning');
    ($w,$d) = (undef,undef);
}

{
    use warnings 'NONFATAL' => 'stricter';
    my (@a, $x) = (0, 1);
    like($w, qr/^Wrong slurpy assignment with \@a in LIST, leaving \$x as undef/,
         "just warn");
    ok(!$d, 'no fatal');
    ($w,$d) = (undef,undef);
}

{
    eval "my (\%h) = 0;";
    like($d, qr/^Odd number of elements in hash assignment/, "fatal");
    ok(!$w, 'no warning');
    ($w,$d) = (undef,undef);
}
