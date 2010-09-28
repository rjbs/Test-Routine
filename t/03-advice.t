use Test::Routine;
use Test::Routine::Runner;
use Test::More;

use namespace::autoclean;

# We're going to give our tests some state.  It's nothing special.
has counter => (
  is   => 'rw',
  isa  => 'Int',
  lazy => 1,
  default => 0,
  clearer => 'clear_counter',
);

test test_0 => sub {
  my ($self) = @_;

  is($self->counter, 0, 'start with counter = 0');
  $self->counter( $self->counter + 1);
  is($self->counter, 1, 'end with counter = 1');
};

test test_1 => sub {
  my ($self) = @_;

  is($self->counter, 0, 'counter is reset between tests');
};

before run_test => sub { $_[0]->clear_counter };

run_me;
done_testing;
