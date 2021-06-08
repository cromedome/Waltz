package Waltz::CLI::Dev;

use v5.20;
use strictures 2;
use Moo;
use Cwd;
use Plack::Runner;
use Plack::Loader::Restarter;
use CLI::Osprey
    desc => 'Run the Waltz development server';

BEGIN {
    my $cwd = getcwd;
    $ENV{ DANCER_CONFDIR } = $cwd;
    $ENV{ DANCER_VIEWS   } = "$cwd/views";
    $ENV{ DANCER_PUBLIC  } = "$cwd/static";
}

use Waltz::App;

sub run {
    my $app    = Waltz::App->to_app;
    my $runner = Plack::Runner->new;

    say 'TODO: render static content. Serving dynamically.';

    $runner->{ loader } = 'Restarter';
    $runner->loader->watch( 'config.yml', 'content', 'prototypes', 'views' );
    $runner->run( $app );
}

1;

