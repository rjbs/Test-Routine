package Test::Routine::Common;
use Moose::Role;

use namespace::autoclean;

use Test::More ();

sub run_test {
  my ($self, $test) = @_;

  my $name = $test->name;
  Test::More::subtest($test->description, sub { $self->$name });
}

1;
