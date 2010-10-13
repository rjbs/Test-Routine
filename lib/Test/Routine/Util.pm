use strict;
use warnings;
package Test::Routine::Util;

use Scalar::Util qw(reftype);

use Test::Routine::Compositor;
use Test::Routine::Runner;

use Sub::Exporter -setup => {
  exports => [
    run_tests => \'_curry_tester',
    run_me    => \'_curry_tester',
  ],
  groups  => [ default   => [ qw(run_me run_tests) ] ],
};

our $UPLEVEL = 0;

sub _curry_tester {
  my ($class, $name, $arg) = @_;

  Carp::confess("the $name generator does not accept any arguments")
    if keys %$arg;

  return sub {
    local $UPLEVEL = $UPLEVEL + 1;
    $class->$name(@_);
  };
}

sub run_me {
  my ($class, $desc, $arg) = @_;

  if (@_ == 2 and (reftype $desc || '') eq 'HASH') {
    ($desc, $arg) = (undef, $arg);
  }

  my $caller = caller($UPLEVEL);

  local $UPLEVEL = $UPLEVEL + 1;
  $class->run_tests($desc, $caller, $arg);
}

sub _runner_class     { 'Test::Routine::Runner' }
sub _compositor_class { 'Test::Routine::Compositor' }

sub run_tests {
  my ($class, $desc, $inv, $arg) = @_;

  my @caller = caller($UPLEVEL);

  $desc = defined($desc)
        ? $desc
        : sprintf 'tests from %s, line %s', $caller[1], $caller[2];

  my $builder = $class->_compositor_class->instance_builder($inv, $arg);

  my $self = $class->_runner_class->new({
    description      => $desc,
    instance_builder => $builder,
  });

  $self->run;
}

1;
