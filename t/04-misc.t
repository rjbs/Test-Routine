use Test::Routine;
use Test::Routine::Runner;
use Test::More;

use namespace::autoclean;

test boring_ordinary_tests => sub {
  pass("This is a plain old boring test that always passes.");
  pass("It's here just to remind you what they look like.");
};

test sample_skip_test => sub {
  plan skip_all => "these tests don't pass, for some reason";

  is(6, 9, "I don't mind.");
};

test sample_todo_test => sub {
  local $TODO = 'demo of todo';

  is(2 + 2, 5, "we can bend the fabric of reality");
};

run_me;
done_testing;
