package Test::Routine::Common;
# ABSTRACT: a role composed by all Test::Routine roles

use Moose::Role;

=head1 OVERVIEW

Test::Routine::Common provides the C<run_test> method described in L<the docs
on writing tests in Test::Routine|Test::Routine/Writing Tests>.

=cut

use Test2::API ();

use namespace::autoclean;

sub run_test {
  my ($self, $test) = @_;

  my $name = $test->name;
  Test2::API::run_subtest($test->description, sub { $self->$name });
}

1;
