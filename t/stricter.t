# -*- mode:perl perl-indent-level:4 -*-
use Test::More tests => 7;
BEGIN { use_ok('stricter') };

my ($w, $d);
local $SIG{__WARN__} = sub { $w = $_[0] };
local $SIG{__DIE__}  = sub { $d = $_[0] };

{
    eval "my (\@a, \$x) = (0, 1);";
    like($d, qr/^Wrong slurpy assignment with \@a in LIST, leaving \$x uninitialized/,
         "fatal stricter");
    ok(!$w, 'no warning stricter');
    ($w,$d) = (undef,undef);
}

if (0) {
    use warnings 'NONFATAL' => 'stricter';
    eval "my (\@a, \$x) = (0, 1);";
    like($w, qr/^Wrong slurpy assignment with \@a in LIST, leaving \$x uninitialized/,
         "NONFATAL stricter");
    ok(!$d, 'no fatal stricter');
    ($w,$d) = (undef,undef);
}

{
    eval "my (\%h) = 0;";
    like($d, qr/^Odd number of elements in hash assignment/, "fatal misc");
    ok(!$w, 'no warning');
    ($w,$d) = (undef,undef);
}

{
    eval "my \%h = (0..3); \$h{0,2}";
    like($d, qr/^Use of multidimensional array emulation/, "fatal multidimensional");
    is($w, undef, 'no warning');
    ($w,$d) = (undef,undef);
}
