use strict;
use warnings;
package Test::Routine::Runner;

use Carp qw(confess);
use Class::MOP ();
use Scalar::Util qw(blessed);
use Test::More ();

use Sub::Exporter::Util qw(curry_method);

use namespace::clean;

use Sub::Exporter -setup => {
  exports => [ run_tests => curry_method ],
  groups  => [ default   => [ 'run_tests' ] ],
};


sub _obj {
  my ($self, $inv, $arg) = @_;

  my $class = Moose::Meta::Class->create_anon_class(
    superclasses => [ 'Moose::Object' ],
    roles        => [ $inv ],
    cache        => 1,
  );

  $class->new($arg);
}

sub run_tests {
  my ($self, $desc, $inv, $arg) = @_;

  confess "can't supply object and args for running tests"
    if blessed $inv and $arg;

  $arg ||= {};

  Class::MOP::load_class($inv) if not blessed $inv;

  my $thing = blessed $inv                          ? $inv
            : $inv->meta->isa('Moose::Meta::Class') ? $inv->new($arg)
            : $inv->meta->isa('Moose::Meta::Role')  ? $self->_obj($inv, $arg)
            : confess "can't handle $inv";

  my @tests = grep { $_->isa('Test::Routine::Test') }
              $thing->meta->get_all_methods;

  for my $test (sort { $a->name cmp $b->name } @tests) {
    my $name = $test->name;
    Test::More::subtest($desc, sub { $thing->$name });
  }
}

1;
