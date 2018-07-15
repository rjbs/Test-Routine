package Test::Routine::Test::Role;
# ABSTRACT: role providing test attributes

use Moose::Role;

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

sub skip_reason { return }

no Moose::Role;

1;
