use v5.20;
use strictures 2;
use Test::More;
use Test::WWW::Mechanize::PSGI;

use Cwd;
use Waltz::App;

BEGIN {
    my $cwd = getcwd;
    $ENV{ DANCER_VIEWS } = "$cwd/share/views";
}

# TODO: Real tests once the app settles
my $mech = Test::WWW::Mechanize::PSGI->new( app => Waltz::App->to_app );
$mech->get_ok( '/' );
$mech->get_ok( '/settings' );
$mech->get_ok( '/version' );

done_testing;
