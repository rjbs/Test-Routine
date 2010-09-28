use strict;
use warnings;
package Test::Routine;
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

sub test {
  my $caller = shift;
  my $name   = shift;
  my $arg    = Params::Util::_HASH0($_[0]) ? { %{shift()} } : {};
  my $code   = shift;

  if (exists $arg->{desc}) {
    Carp::confess "can't supply both 'desc' and 'description'"
      if exists $arg->{description};

    $arg->{description} = delete $arg->{desc};
  }

  my $class = Moose::Meta::Class->initialize($caller);

  my $method = Test::Routine::Test->wrap(
    %$arg,
    name => $name,
    body => $code,
    package_name => $caller,
  );

  $class->add_method($name => $method);
}

1;
