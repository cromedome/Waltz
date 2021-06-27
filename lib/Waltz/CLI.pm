package Waltz::CLI;

use v5.20;
use Moo;
use strictures 2;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use CLI::Osprey;
use File::Share 'dist_dir';
use Module::Runtime 'use_module';
use Text::Table::Tiny qw( generate_table );

# TODO: All of these
subcommand version   => 'Waltz::CLI::Version';
#subcommand validate  => 'Waltz::CLI::Validate';
#subcommand search    => 'Waltz::CLI::Search';
#subcommand init      => 'Waltz::CLI::Init';
#subcommand create    => 'Waltz::CLI::Create';
#subcommand plaintext => 'Waltz::CLI::Plaintext';
subcommand publish   => 'Waltz::CLI::Publish'; # Create static content
#subcommand deploy    => 'Waltz::CLI::Deploy'; # Implies publish. Push to render, Netlify, GitHub, etc.
subcommand dev       => 'Waltz::CLI::Dev';
#subcommand bootstrap => 'Waltz::CLI::Bootstrap';

# Thinking ahead, these might be useful in future subcommands
has _waltz_version => (
    is      => 'lazy',
    builder => sub { use_module( 'Waltz' )->VERSION },
);

has _dist_dir => (
    is      => 'lazy',
    builder => sub{ dist_dir('Waltz') },
);

sub run( $self ) {
    return $self->osprey_usage;
}

sub display_stats( $self, $stats ) {
    my @rows = ( [ qw/ Statistic Time(s) / ] );
    push @rows, [ '# of Markdown Files Generated', $stats->{ num_pages } ];
    push @rows, [ '# of static Files Published', $stats->{ num_static_files } ];
    push @rows, [ 'Total Time (secs)', $stats->{ total_time } ];
    say generate_table( rows => \@rows, header_row => 1 );
}

1;

