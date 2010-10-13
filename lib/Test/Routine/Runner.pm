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
use Test::More ();

use Moose::Util::TypeConstraints;

use namespace::clean;

subtype 'Test::Routine::InstanceBuilder', as 'CodeRef';
subtype 'Test::Routine::Instance',
  as 'Object',
  where { $_->does('Test::Routine::Common') };

coerce 'Test::Routine::InstanceBuilder',
  from 'Test::Routine::Instance',
  via  { my $instance = $_; sub { $instance } };

has test_instance => (
  is   => 'ro',
  does => 'Test::Routine::Common',
  init_arg   => undef,
  lazy_build => 1,
);

has instance_builder => (
  is  => 'ro',
  isa => 'Test::Routine::InstanceBuilder',
  coerce   => 1,
  traits   => [ 'Code' ],
  init_arg => 'test_instance',
  required => 1,
  handles  => {
    '_build_test_instance' => 'execute_method',
  },
);

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
