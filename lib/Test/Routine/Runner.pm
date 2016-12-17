package Test::Routine::Runner;
# ABSTRACT: tools for running Test::Routine tests

use Moose;

=head1 OVERVIEW

A Test::Routine::Runner takes a callback for building test instances, then uses
it to build instances and run the tests on it.  The Test::Routine::Runner
interface is still undergoing work, but the Test::Routine::Util exports for
running tests, described in L<Test::Routine|Test::Routine/Running Tests>, are
more stable.  Please use those instead, unless you are willing to deal with
interface breakage.

=cut

use Carp qw(confess croak);
use Scalar::Util qw(reftype);
use Test2::API 1.302045 ();
use Try::Tiny;

use Moose::Util::TypeConstraints;

use namespace::clean;

# XXX: THIS CODE BELOW WILL BE REMOVED VERY SOON -- rjbs, 2010-10-18
use Sub::Exporter -setup => {
  exports => [
    run_tests => \'_curry_tester',
    run_me    => \'_curry_tester',
  ],
  groups  => [ default   => [ qw(run_me run_tests) ] ],
};

sub _curry_tester {
  my ($class, $name) = @_;
  use Test::Routine::Util;
  my $sub = Test::Routine::Util->_curry_tester($name);

  return sub {
    warn "you got $name from Test::Routine::Runner; use Test::Routine::Util instead; Test::Routine::Runner's exports will be removed soon\n";
    goto &$sub;
  }
}
# XXX: THIS CODE ABOVE WILL BE REMOVED VERY SOON -- rjbs, 2010-10-18

subtype 'Test::Routine::_InstanceBuilder', as 'CodeRef';
subtype 'Test::Routine::_Instance',
  as 'Object',
  where { $_->does('Test::Routine::Common') };

coerce 'Test::Routine::_InstanceBuilder',
  from 'Test::Routine::_Instance',
  via  { my $instance = $_; sub { $instance } };

has test_instance => (
  is   => 'ro',
  does => 'Test::Routine::Common',
  init_arg   => undef,
  lazy_build => 1,
);

has _instance_builder => (
  is  => 'ro',
  isa => 'Test::Routine::_InstanceBuilder',
  coerce   => 1,
  traits   => [ 'Code' ],
  init_arg => 'instance_from',
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

  my @tests = grep { Moose::Util::does_role($_, 'Test::Routine::Test::Role') }
              $thing->meta->get_all_methods;

  my $re = $ENV{TEST_METHOD};
  if (defined $re and length $re) {
    my $filter = try { qr/$re/ } # compile the the regex separately ...
        catch { croak("TEST_METHOD ($re) is not a valid regular expression: $_") };
    $filter = qr/\A$filter\z/;  # ... so it can't mess with the anchoring
    @tests = grep { $_->description =~ $filter } @tests;
  }

  # As a side note, I wonder whether there is any way to format the code below
  # to not look stupid. -- rjbs, 2010-09-28
  my @ordered_tests = sort {
         $a->_origin->{file} cmp $b->_origin->{file}
      || $a->_origin->{nth}  <=> $b->_origin->{nth}
  } @tests;

  Test2::API::run_subtest($self->description, sub {
    for my $test (@ordered_tests) {
      $self->test_instance->run_test( $test );
      $self->clear_test_instance if $self->fresh_instance;
    }
  });
}

1;
