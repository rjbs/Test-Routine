package Test::Routine::Runner;
use Moose;
# ABSTRACT: tools for running Test::Routine tests

=head1 OVERVIEW

Test::Routine::Runner is documented in L<the Test::Routine docs on running
tests|Test::Routine/Running Tests>.  Please consult those for more information.

Both C<run_tests> and C<run_me> are methods on Test::Routine::Runner, and are
exported by default with the invocant curried.  This means that you can write a
subclass of Test::Routine::Runner with different behavior.  Do this cautiously.
Although the basic behaviors of the runner are unlikely to change, they are not
yet set entirely in stone.

=cut

use Carp qw(confess);
use Scalar::Util qw(reftype);
use Test::Routine::Compositor;
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

has test_instance => (
  is   => 'ro',
  does => 'Test::Routine::Common',
  init_arg   => undef,
  lazy_build => 1,
);

has instance_builder => (
  is  => 'ro',
  isa => 'CodeRef',
  traits  => [ 'Code' ],
  handles => {
    '_build_test_instance' => 'execute_method',
  },
);

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

sub run_tests {
  my ($class, $desc, $inv, $arg) = @_;

  my @caller = caller($UPLEVEL);

  $desc = defined($desc)
        ? $desc
        : sprintf 'tests from %s, line %s', $caller[1], $caller[2];

  my $builder = Test::Routine::Compositor->instance_builder($inv, $arg);

  my $self = $class->new({
    description      => $desc,
    instance_builder => $builder,
  });

  $self->run;
}

has description => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

has fresh_instance => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

sub run {
  my ($self) = @_;

  my $thing = $self->test_instance;

  my @tests = grep { $_->isa('Test::Routine::Test') }
              $thing->meta->get_all_methods;

  # As a side note, I wonder whether there is any way to format the code below
  # to not look stupid. -- rjbs, 2010-09-28
  my @ordered_tests = sort {
         $a->_origin->{file} cmp $b->_origin->{file}
      || $a->_origin->{nth}  <=> $a->_origin->{nth}
  } @tests;

  Test::More::subtest($self->description, sub {
    for my $test (@ordered_tests) {
      $self->test_instance->run_test( $test );
      $self->clear_test_instance if $self->fresh_instance;
    }
  });
}

1;
