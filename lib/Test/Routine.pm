use strict;
use warnings;
package Test::Routine;
# ABSTRACT: composable units of assertion

=head1 SYNOPSIS

B<The interface of Test::Routine is still open to some changes.>

  # mytest.t
  use Test::More;
  use Test::Routine;
  use Test::Routine::Util;

  has fixture => (
    is   => 'ro',
    lazy => 1,
    clearer => 'reset_fixture',
    default => sub { ...expensive setup... },
  );

  test "we can use our fixture to do stuff" => sub {
    my ($self) = @_;

    $self->reset_fixture; # this test requires a fresh one

    ok( $self->fixture->do_things, "do_things returns true");
    ok( ! $self->fixture->no_op,   "no_op returns false");

    for my $item ($self->fixture->contents) {
      isa_ok($item, 'Fixture::Entry');
    }
  };

  test "fixture was recycled" => sub {
    my ($self) = @_;

    my $fixture = $self->fixture; # we don't expect a fresh one

    is( $self->fixture->things_done, 1, "we have done one thing already");
  };

  test_me;
  done_testing;

=head1 DESCRIPTION

Test::Routine is a very simple framework for writing your tests as composable
units of assertion.  In other words: roles.

For a walkthrough of tests written with Test::Routine, see
L<Test::Routine::Manual::Demo>.

Test::Routine is similar to L<Test::Class> in some ways.  These similarities
are largely superficial, but the idea of "tests bound together in reusable
units" is a useful one to understand when coming to Test::Routine.  If you are
already familiar with Test::Class, it is the differences rather than the
similarities that will be more important to understand.  If you are not
familiar with Test::Class, there is no need to understand it prior to using
Test::Routine.

On the other hand, an understanding of the basics of L<Moose> is absolutely
essential.  Test::Routine composes tests from Moose classes, roles, and
attributes.  Without an understanding of those, you will not be able to use
Test::Routine.  The L<Moose::Manual> is an excellent resource for learning
Moose, and has links to other online tutorials and documentation.

=head2 The Concepts

=head2 The Basics of Using Test::Routine

There actually isn't much to Test::Routine I<other> than the basics.  It does
not provide many complex features, instead delegating almost everything to the
Moose object system.

=head3 Writing Tests

To write a set of tests (a test routine, which is a role), you add C<use
Test::Routine;> to your package.  C<main> is an acceptable target for turning
into a test routine, meaning that you may use Test::Routine in your F<*.t>
files in your distribution.

C<use>-ing Test::Routine will turn your package into a role that composes
L<Test::Routine::Common>, and will give you the C<test> declarator for adding
tests to your routine.  Test::Routine::Common adds the C<run_test> method that
will be called to run each test.

The C<test> declarator is very simple, and will generally be called like this:

  test $NAME_OF_TEST => sub {
    my ($self) = @_;

    is($self->foo, 123, "we got the foo we expected");
    ...
    ...
  };

This defines a test with a given name, which will be invoked like a method on
the test object (described below).  Tests are ordered by declaration within the
file, but when multiple test routines are run in a single test, the ordering of
the routines is B<undefined>.

C<test> may also be given a different name for the installed method and the
test description.  This isn't usually needed, but can make things clearer when
referring to tests as methods:

  test $NAME_OF_TEST_METHOD => { description => $TEST_DESCRIPTION } => sub {
    ...
  }

Each test will be run by the C<run_test> method.  To add setup or teardown
behavior, advice (method modifiers) may be attached to that method.  For
example, to call an attribute clearer before each test, you could add:

  before run_test => sub {
    my ($self) = @_;

    $self->clear_some_attribute;
  };

=head3 Running Tests

To run tests, you will need to use L<Test::Routine::Util>, which will provide
two functions for running tests: C<run_tests> and C<run_me>.  The former is
given a set of packages to compose and run as tests.  The latter runs the
caller, assuming it to be a test routine.

C<run_tests> can be called in several ways:

  run_tests( $desc, $object );

  run_tests( $desc, \@packages, $arg );

  run_tests( $desc, $package, $arg );  # equivalent to ($desc, [$pkg], $arg)

In the first case, the object is assumed to be a fully formed, testable object.
In other words, you have already created a class that composes test routines
and have built an instance of it.

In the other cases, C<run_tests> will produce an instance for you.  It divides
the given packages into classes and roles.  If more than one class was given,
an exception is thrown.  A new class is created subclassing the given class and
applying the given roles.  If no class was in the list, Moose::Object is used.
The new class's C<new> is called with the given C<$arg> (if any).

The composition mechanism makes it easy to run a test routine without first
writing a class to which to apply it.  This is what makes it possible to write
your test routine in the C<main> package and run it directly from your F<*.t>
file.  The following is a valid, trivial use of Test::Routine:

  use Test::More;
  use Test::Routine;
  use Test::Routine::Util;

  test demo_test => sub { pass("everything is okay") };

  run_tests('our tests', 'main');
  done_testing;

In this circumstance, though, you'd probably use C<run_me>, which runs the
tests in the caller.  You'd just replace the C<run_tests> line with
C<< run_me; >>.  A description for the run may be supplied, if you like.

Each call to C<run_me> or C<run_tests> generates a new instance, and you can
call them as many times, with as many different arguments, as you like.  Since
Test::Routine can't know how many times you'll call different test routines,
you are responsible for calling C<L<done_testing|Test::More/done_testing>> when
you're done testing.

=cut

use Moose::Exporter;

use Moose::Role ();
use Moose::Util ();
use Scalar::Util ();

use Test::Routine::Common;
use Test::Routine::Test;

Moose::Exporter->setup_import_methods(
  with_caller => [ qw(test) ],
  also        => 'Moose::Role',
);

sub init_meta {
  my ($class, %arg) = @_;

  my $meta = Moose::Role->init_meta(%arg);
  my $role = $arg{for_class};
  Moose::Util::apply_all_roles($role, 'Test::Routine::Common');

  return $meta;
}

my $i = 0;
sub test {
  my $caller = shift;
  my $name   = shift;
  my $arg    = Params::Util::_HASH0($_[0]) ? { %{shift()} } : {};
  my $body   = shift;

  # This could really have been done with a MooseX like InitArgs or Alias in
  # Test::Routine::Test, but since this is a test library, I'd actually like to
  # keep prerequisites fairly limited. -- rjbs, 2010-09-28
  if (exists $arg->{desc}) {
    Carp::confess "can't supply both 'desc' and 'description'"
      if exists $arg->{description};
    $arg->{description} = delete $arg->{desc};
  }

  my $class = Moose::Meta::Class->initialize($caller);

  my %origin;
  @origin{qw(file line nth)} = ((caller(0))[1,2], $i++);

  my $method = Test::Routine::Test->wrap(
    %$arg,
    name => $name,
    body => $body,
    package_name => $caller,
    _origin      => \%origin,
  );

  $class->add_method($name => $method);
}

1;
