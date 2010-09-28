package Test::Routine::Test;
use Moose;
extends 'Moose::Meta::Method';

has description => (
  is   => 'ro',
  isa  => 'Str',
  lazy => 1,
  default => sub { $_[0]->name },
);

has _origin => (
  is  => 'ro',
  isa => 'HashRef',
  required => 1,
);

1;
