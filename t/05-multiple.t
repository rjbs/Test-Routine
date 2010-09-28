#!/bin/env perl
use strict;
use warnings;

use Test::Routine::Runner;
use Test::More;

{
  package Time::Moves::Forward;
  use Test::Routine;
  use Test::More;
  use namespace::autoclean;

  requires 'get_time';
  requires 'epoch_end';

  test no_temporal_regression => sub {
    my ($self) = @_;

    cmp_ok(
      $self->get_time, '>=', $^T,
      "it is no earlier than when the program started",
    );

    cmp_ok(
      $self->epoch_end, '>=', $^T,
      "the timer epoch is not in the past, either",
    );
  };
}

{
  package Time::Reasonable;
  use Test::Routine;
  use Test::More;
  use namespace::autoclean;

  requires 'get_time';
  requires 'epoch_start';

  test time_looks_sane => sub {
    my ($self) = @_;

    my $now = $self->get_time;
    like($now, qr/\A[0-9]+\z/, "time is a string of ascii digits");

    cmp_ok($now, '>=', $self->epoch_start, "time is after epoch start");
  }
}

{
  package TimePiece;
  use Moose;
  use namespace::autoclean;

  has offset => (is => 'ro', isa => 'Int', default => 0, required => 1);

  sub epoch_start { 0 }
  sub epoch_end   { $^T + 86_400 }

  sub get_time {
    my ($self) = @_;

    return time + $self->offset;
  }
}

run_tests(
  "offset an hour into the future",
  [ qw(TimePiece Time::Reasonable Time::Moves::Forward) ],
  { offset => 3600 },
);

# ...and we're done!
done_testing;
