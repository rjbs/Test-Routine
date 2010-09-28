package Test::Routine::Common;
use Moose::Role;

use namespace::autoclean;

use Test::More ();

sub run_test {
  my ($self, $test_name) = @_;

  Test::More::subtest($test_name, sub { $self->$test_name });
}

1;
