#!/bin/env perl
use strict;
use lib 't/lib';

use Test::Routine::Runner;

run_tests(foo => 'EnvHash');
