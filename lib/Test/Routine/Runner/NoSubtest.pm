use v5.12.0;
package Test::Routine::Runner::NoSubtest;
# ABSTRACT: tools for running Test::Routine tests (without using a subtest)

use Moose;
extends 'Test::Routine::Runner';

=head1 OVERVIEW

This is just a L<Test::Routine::Runner>, but when you call C<run>, it won't
wrap the whole thing in a subtest.  If you use multiple instances of a
Test::Routine object in testing -- constructing it with different parameters
for several runs, for example -- this will lead to heartache.  If your test is
just a single run, though, getting rid of that top-level subtest can simplify
your life.

Also: if no tests will be run, generally because the C<TEST_METHOD> environment
variable didn't select them, then a "skip all" will be issued.

=cut

use Test2::API 1.302045 ();

sub run {
  my ($self) = @_;

  my $test_instance = $self->build_test_instance;

  my $ordered_tests = $self->_get_tests($test_instance);

  if (@$ordered_tests == 0) {
    my $ctx = Test2::API::context;
    $ctx->plan(0, 'SKIP', "no tests to run");
    $ctx->release;

    return;
  }

  $self->_run_tests($test_instance, $ordered_tests);
}

no Moose;
1;
