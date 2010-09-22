package EnvHash;
use Moose;
with 'HashTester';

sub _build_fixture {
  return { $$ => $^T };
}

1;
