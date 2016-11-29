package Test::Routine::Common;
# ABSTRACT: a role composed by all Test::Routine roles

use Moose::Role;

=head1 OVERVIEW

Test::Routine::Common provides the C<run_test> method described in L<the docs
on writing tests in Test::Routine|Test::Routine/Writing Tests>.

=cut

use Test2::API 1.302045 ();

use namespace::autoclean;

sub run_test {
  my ($self, $test) = @_;

  my $ctx = Test2::API::context();
  my ($file, $line) = @{ $test->_origin }{ qw(file line) };
  $ctx->trace->set_detail("at $file line $line");

  my $name = $test->name;
  Test2::API::run_subtest($test->description, sub { $self->$name });

  $ctx->release;
}

1;
