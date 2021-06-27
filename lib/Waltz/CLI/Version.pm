package Waltz::CLI::Version;

use Moo;
use CLI::Osprey
    desc => 'Display version of Waltz';

sub run {
    my $self = shift;
    print "Waltz " . $self->parent_command->_waltz_version, "\n";
}

1;


