#!/usr/bin/env perl

use strictures 2;
use Waltz::App;
use Plack::Runner;
use Plack::Loader::Restarter;

my $app    = Waltz::App->to_app;
my $runner = Plack::Runner->new;

$runner->{ loader } = 'Restarter';
$runner->loader->watch( 'lib' );
$runner->run( $app );
exit 0;
 
