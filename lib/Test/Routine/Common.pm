package Test::Routine::Common;
use Moose::Role;
# ABSTRACT: a role composed by all Test::Routine roles

=head1 OVERVIEW

Test::Routine::Common provides the C<run_test> method described in L<the docs
on writing tests in Test::Routine|Test::Routine/Writing Tests>.

=cut

use Test::More ();

use namespace::autoclean;

sub run_test {
  my ($self, $test) = @_;

  my $name = $test->name;
  Test::More::subtest($test->description, sub { $self->$name });
}

1;
