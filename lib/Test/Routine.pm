use strict;
use warnings;
package Test::Routine;
use Moose::Exporter;

use Moose::Role ();
use Moose::Util ();

Moose::Exporter->setup_import_methods(
  with_caller => [ qw(test) ],
  also        => 'Moose::Role',
);

# sub init_meta {
#   my ($class, %arg) = @_;
# 
#   my $meta = Moose::Role->init_meta(%arg);
#   my $role = $arg{for_class};
#   Moose::Util::apply_all_roles($role, 'Test::Routine::Runnable');
# 
#   return $meta;
# }

{
  package Test::Routine::Test;
  use Moose;
  extends 'Moose::Meta::Method';
  no Moose;
}

sub test {
  my ($caller, $name, $code) = @_;
  $name  = "Test_Routine:$name";

  my $class = Moose::Meta::Class->initialize($caller);

  my $method = Test::Routine::Test->wrap(
    name => $name,
    body => $code,
    package_name => $caller,
  );

  $class->add_method($name => $method);
}


1;
