use strict;
use warnings;
package Test::Routine;
use Moose::Exporter;

use Moose::Role ();
use Moose::Util ();
use Scalar::Util ();

Moose::Exporter->setup_import_methods(
  with_caller => [ qw(test) ],
  also        => 'Moose::Role',
);

{
  package Test::Routine::Test;
  use Moose;
  extends 'Moose::Meta::Method';
  no Moose;
}

sub test {
  my ($caller, $name, $code) = @_;

  my $class = Moose::Meta::Class->initialize($caller);

  my $method = Test::Routine::Test->wrap(
    name => $name,
    body => $code,
    package_name => $caller,
  );

  $class->add_method($name => $method);
}


1;
