use strict;
use warnings;
package Test::Routine::Runner;

use Carp qw(confess);
use Class::MOP ();
use Moose::Meta::Class;
use Scalar::Util qw(blessed reftype);
use Test::More ();

use Sub::Exporter::Util qw(curry_method);

use namespace::clean;

use Sub::Exporter -setup => {
  exports => [
    run_tests => \'_curry_tester',
    run_me    => \'_curry_tester',
  ],
  groups  => [ default   => [ qw(run_me run_tests) ] ],
};

sub _obj {
  my ($inv, $arg) = @_;

  my $class = Moose::Meta::Class->create_anon_class(
    superclasses => [ 'Moose::Object' ],
    roles        => [ $inv ],
    cache        => 1,
  );

  $class->name->new($arg);
}

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

  if (@_ == 2 and (reftype $desc // '') eq 'HASH') {
    ($desc, $arg) = (undef, $arg);
  }

  my $caller = caller($UPLEVEL);

  local $UPLEVEL = $UPLEVEL + 1;
  $class->run_tests($desc, $caller, $arg);
}

sub run_tests {
  my ($class, $desc, $inv, $arg) = @_;

  my @caller = caller($UPLEVEL);

  $desc //= sprintf 'tests from %s, line %s', $caller[1], $caller[2];

  confess "can't supply object and args for running tests"
    if blessed $inv and $arg;

  $arg //= {};

  Class::MOP::load_class($inv) if not blessed $inv;

  my $thing = blessed $inv                          ? $inv
            : $inv->meta->isa('Moose::Meta::Class') ? $inv->new($arg)
            : $inv->meta->isa('Moose::Meta::Role')  ? _obj($inv, $arg)
            : confess "can't handle $inv";

  my @tests = grep { $_->isa('Test::Routine::Test') }
              $thing->meta->get_all_methods;

  Test::More::subtest($desc, sub {
    for my $test (sort { $a->name cmp $b->name } @tests) {
      my $name = $test->name;
      Test::More::subtest($name, sub { $thing->$name });
    }
  });
}

1;
