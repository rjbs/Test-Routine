use strict;
use warnings;
package Test::Routine;
# ABSTRACT: composable units of assertion

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
