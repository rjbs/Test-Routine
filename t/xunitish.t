use Test::Routine::xUnitish;
use Test::Routine::Util;
use Test::More;

use namespace::autoclean;

has counter => (
    is => 'rw',
    isa => 'Int',
    default => 0,
    lazy => 1,
    auto_clear => 1,
);

test "first" => sub {
    my($self) = @_;

    is($self->counter, 0, "Always starting from zero");
    $self->counter( 1 );
    is($self->counter, 1, "And going to 1");
};

test "second" => sub {
    my($self) = @_;

    is($self->counter, 0, "Always starting from zero");
    $self->counter( 1 );
    is($self->counter, 1, "And going to 1");
};

run_me;
done_testing;
