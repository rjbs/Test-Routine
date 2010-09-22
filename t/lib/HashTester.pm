package HashTester;
use lib 'lib';
use Test::Routine;
use Test::More;

use namespace::autoclean;

has fixture => (
  is  => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);

test foo => sub {
  my ($self) = @_;

  my $fixture = $self->fixture;

  is(keys %$fixture, 1, "we have one key in our fixture");
};

1;
