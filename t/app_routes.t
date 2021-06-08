use v5.20;
use strictures 2;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Cwd;

my $cwd;
BEGIN {
    $cwd = getcwd;
    $cwd = "$cwd/t";
    $ENV{ DANCER_VIEWS } = "$cwd/views";
    $ENV{ DANCER_CONFDIR } = $cwd;
}

# Must happen *after* the begin block. Order matters!
use Waltz::App;

# Make sure content is based on the right directory
chdir $cwd;

# TODO: Real tests once the app settles
my $mech = Test::WWW::Mechanize::PSGI->new( app => Waltz::App->to_app );
$mech->get_ok( '/' );
$mech->get_ok( '/version' );

done_testing;
