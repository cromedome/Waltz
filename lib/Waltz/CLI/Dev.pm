package Waltz::CLI::Dev;

use Moo;
use CLI::Osprey
    desc => 'Run the Waltz development server';

use strictures 2;
use Waltz::App;
use Plack::Runner;
use Plack::Loader::Restarter;

sub run {
    my $app    = Waltz::App->to_app;
    my $runner = Plack::Runner->new;

    $runner->{ loader } = 'Restarter';
    $runner->loader->watch( 'lib', 'bin' );
    $runner->run( $app );
}

1;


