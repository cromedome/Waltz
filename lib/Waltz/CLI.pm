package Waltz::CLI;

use Moo;
use CLI::Osprey;
use File::Share 'dist_dir';
use Module::Runtime 'use_module';

# TODO: All of these
subcommand version   => 'Waltz::CLI::Version';
#subcommand validate  => 'Waltz::CLI::Validate';
#subcommand search    => 'Waltz::CLI::Search';
#subcommand site      => 'Waltz::CLI::Site';
#subcommand page      => 'Waltz::CLI::Page';
#subcommand publish   => 'Waltz::CLI::Publish';
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

sub run {
    my $self = shift;
    return $self->osprey_usage;
}

1;

