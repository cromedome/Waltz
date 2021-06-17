package Waltz::CLI::Publish;

use v5.20;
use strictures 2;
use Moo;
use Cwd;
use YAML qw( LoadFile );
use CLI::Osprey
    desc => 'Publish a site to static HTML files.';

use Waltz::Renderer;

my $cwd;
BEGIN {
    $cwd = getcwd;
    $ENV{ DANCER_CONFDIR } = $cwd;
    $ENV{ DANCER_VIEWS   } = "$cwd/views";
    $ENV{ DANCER_PUBLIC  } = "$cwd/static";
}

sub run {
    my $config   = LoadFile $ENV{ DANCER_CONFDIR } . "/config.yml";
    my $renderer = Waltz::Renderer->new({ basedir => $cwd, config => $config });
    $renderer->render_all;
}

1;

