# -*- mode:perl perl-indent-level:4 -*-
use Test::More tests => 2;
BEGIN { use_ok('stricter') };

my $w;
local $SIG{__WARN__} = sub { $w = $_[0] };

my (@a, $x) = (0, 1);
like($w, qr/^Invalid/, "warning");
