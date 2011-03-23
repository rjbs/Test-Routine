#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
use Test::Fatal;
use Test::Builder::Tester;

BEGIN {
    eval { require MooseX::Method::Signatures; 1 }
        || plan skip_all => "This test requires MooseX::Method::Signatures";
}

{
    package Test::Foo;
    use Test::Routine;
    use Test::Routine::Util;
    use MooseX::Method::Signatures;

    ::is(::exception {
        test 'foo bar' => method {
            ::does_ok($self, 'Test::Foo');
        };
    }, undef, "can create tests with methods");

    ::test_out("        ok 1 - The object does Test::Foo");
    ::test_out("        1..1");
    ::test_out("    ok 1 - foo bar");
    ::test_out("    1..1");
    ::test_out("ok 1 - tests work");
    run_me('tests work');
    ::test_test();
}

{
    package Test::Bar;
    use Test::Routine;
    use Test::Routine::Util;
    use MooseX::Method::Signatures;

    ::is(::exception {
        test 'foo bar' => { description => 'foobar' } => method {
            ::does_ok($self, 'Test::Bar');
        };
    }, undef, "can create tests with methods");

    ::test_out("        ok 1 - The object does Test::Bar");
    ::test_out("        1..1");
    ::test_out("    ok 1 - foobar");
    ::test_out("    1..1");
    ::test_out("ok 1 - tests work");
    run_me('tests work');
    ::test_test();
}

done_testing;
