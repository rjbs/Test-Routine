package Test::Routine::Meta::Attribute::Trait::AutoClear;
use Moose::Role;

package Moose::Meta::Attribute::Custom::Trait::AutoClear;
sub register_implementation {
    'Test::Routine::Meta::Attribute::Trait::AutoClear';
}

package Test::Routine::AutoClear;
use Moose::Role;

after run_test => sub {
    my $self = shift;

    $_->clear_value($self) foreach grep {
        $_->does( 'Test::Routine::Meta::Attribute::Trait::AutoClear' )
    } $self->meta->get_all_attributes;
};

1;

