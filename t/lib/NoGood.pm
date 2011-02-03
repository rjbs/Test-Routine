package t::lib::NoGood;
use Test::Routine;

test "this will be duplicated" => sub { ... };

test "this will be duplicated" => sub { ... };

1;
