#!/bin/env perl
use strict;
use lib 't/lib';

use Test::Routine::Runner;
use Test::More;


{
  package HashTester;
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
}

{
  package EnvHash;
  use Moose;
  with 'HashTester';

  use namespace::autoclean;

  sub _build_fixture { return { $$ => $^T } }
}

run_tests('EnvHash tests' => 'EnvHash');

run_tests(
  'HashTester with given state',
  HashTester => {
    fixture => { a => 1 },
  },
);

done_testing;
