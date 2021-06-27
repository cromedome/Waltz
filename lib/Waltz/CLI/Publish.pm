package Waltz::CLI::Publish;

use v5.20;
use Moo;
use strictures 2;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use Cwd;
use YAML qw( LoadFile );
use CLI::Osprey
    desc => 'Publish a site to static HTML files.';
use Text::Table::Tiny qw( generate_table );
use Waltz::Renderer;

my $cwd;
BEGIN {
    $cwd = getcwd;
    $ENV{ DANCER_CONFDIR } = $cwd;
    $ENV{ DANCER_VIEWS   } = "$cwd/views";
    $ENV{ DANCER_PUBLIC  } = "$cwd/static";
}

option verbose => (
    is       => 'ro',
    short    => 'v',
    doc      => "verbose output",
    required => 0,
    default  => 0,
);

sub run( $self ) {
    my $config   = LoadFile $ENV{ DANCER_CONFDIR } . "/config.yml";
    my $renderer = Waltz::Renderer->new({ basedir => $cwd, config => $config });
    my $stats    = $renderer->render_all;

    if( $self->verbose ) {
        say "Static Files published:";
        say "- $_" foreach $stats->{ static_files }->@*;

        say "\nMarkdown Files processed:";
        my @rows = ( [ qw/ Filename Time(s) / ] );
        my $md_files = $stats->{ md_files };
        for my $md_file( keys $md_files->%* ) {
            my $time = $md_files->{ $md_file };
            push @rows, [ $md_file, $time ];
        }
        say generate_table( rows => \@rows, header_row => 1 ), "\n";
    }

    $self->parent_command->display_stats( $stats );
    say "\nAll content is available in public/ - Happy Waltzing!\n";
}

1;

