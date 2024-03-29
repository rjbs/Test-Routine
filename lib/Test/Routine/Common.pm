use v5.12.0;
package Test::Routine::Common;
# ABSTRACT: a role composed by all Test::Routine roles

use Moose::Role;

=head1 OVERVIEW

Test::Routine::Common provides the C<run_test> method described in L<the docs
on writing tests in Test::Routine|Test::Routine/Writing Tests>.

=cut

use Test::Abortable 0.002 ();
use Test2::API 1.302045 ();

use namespace::autoclean;

sub BUILD {
}

sub DEMOLISH {
}

sub run_test {
  my ($self, $test) = @_;

  my $ctx = Test2::API::context();
  my ($file, $line) = @{ $test->_origin }{ qw(file line) };
  $ctx->trace->set_detail("at $file line $line");

  my $name = $test->name;

  # Capture and return whether the test as a whole succeeded or not
  my $rc = Test::Abortable::subtest($test->description, sub { $self->$name });

  $ctx->release;

  return $rc;
}

1;
