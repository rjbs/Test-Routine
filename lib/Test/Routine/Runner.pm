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
    run_tests => sub { \&_run_tests }
  ],
  groups  => [ default   => [ 'run_tests' ] ],
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

sub run_tests {
  my ($self, $desc, $inv, $arg) = @_;

  local $UPLEVEL = 1;
  _run_tests($desc, $inv, $arg);
}

sub _run_tests {
  # Too much magic, we just want different run_tests-like routines, I think.
  # -- rjbs, 2010-09-23
  if (@_ == 1 and ! blessed $_[0]) {
    if ((reftype $_[0]  // '') eq 'HASH') {
      @_ = (undef, undef, $_[0]);
    }
  }

  my ($desc, $inv, $arg) = @_;

  my @caller = caller($UPLEVEL);

  $desc //= sprintf 'tests from %s, line %s', $caller[1], $caller[2];
  $inv  //= $caller[0];

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
