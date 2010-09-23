use Test::Routine;
use Test::Routine::Runner;
use Test::More;

has counter => (
  is  => 'rw',
  isa => 'Int',
  default => 0,
);

test 'alphabetically first' => sub {
  my ($self) = @_;
  is($self->counter, 0, "start with counter zero");

  $self->counter( $self->counter + 1);
};

test 'everything counts' => sub {
  my ($self) = @_;
  is($self->counter, 1, "state preserved (we are just an object)");
};

test 'in small amounts' => sub {
  my ($self) = @_;

  ok(1);
};

run_tests;
don_testing;
