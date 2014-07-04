package Test::Routine::Test;
# ABSTRACT: a test method in a Test::Routine role

use Moose;
extends 'Moose::Meta::Method';

with 'Test::Routine::Test::Role';

=head1 OVERVIEW

Test::Routine::Test is a very simple subclass of L<Moose::Meta::Method>, used
primarily to identify which methods in a class are tests.  It also has
attributes used for labeling and ordering test runs.

=cut

1;
