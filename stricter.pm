package stricter;

use 5.006;
use strict;
our $VERSION = '0.01';
use XSLoader ();

XSLoader::load;

1;
__END__

=head1 NAME

stricter - than strict

=head1 SYNOPSIS

  use stricter;
  my (@a, $x) = (1, 2);
  => Invalid ...

=head1 DESCRIPTION

Adds stricter compile-time checks than strict.

=head1 SEE ALSO

L<strict>

=head1 AUTHOR

Reini Urban, E<lt>rurban@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by cPanel Inc

This library is free software; you can redistribute it and/or modify
it under the terms of the Artistic License 2.0.

=cut
