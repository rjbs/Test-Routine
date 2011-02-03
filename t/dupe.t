use strict;
use warnings;

use Test::More;
use Test::Fatal;

my $err = exception { require t::lib::NoGood };
like(
  $err,
  qr/with the same name/,
  "having two tests with the same name is disallowed",
);

done_testing;
