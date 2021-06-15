use v5.20;
use strictures 2;
use Test::Most;
use Test::WWW::Mechanize::PSGI;
use Cwd;
use YAML qw( LoadFile );

use Waltz::Renderer;

my $cwd;
BEGIN {
    $cwd = getcwd;
    unless( $cwd =~ /t$/ ) {
        $cwd = "$cwd/t";
    }
    $ENV{ DANCER_VIEWS   } = "$cwd/views";
    $ENV{ DANCER_CONFDIR } = $cwd;
    $ENV{ DANCER_APPDIR  } = $cwd;
}

# Make sure App test runs from right directory
chdir 't';
use Waltz::App;

my $no_default_config = Waltz::Renderer->new({ basedir => $cwd });
dies_ok { 
    $no_default_config->render({ 
        filename => 'blog/hello-world',
        uri      => 'http://localhost:5000/blog/hello-world',
    }) 
} 'Renderer dies when no config provided';

my $config = LoadFile $ENV{ DANCER_CONFDIR } . "/config.yml";
lives_ok { Waltz::Renderer->new({ basedir => $cwd, config => $config }) } 
    '...but lives when we have config';

my $renderer = Waltz::Renderer->new({ basedir => $cwd, config => $config });
my $output   = $renderer->render({
    filename => 'index',
    uri      => '/index',
});

cmp_ok( scalar keys $output->%*, '>', 0, '...and renders too!' );

is( $output->{ prototype }, 'default', 'render() uses a default prototype when none given' );

$output = $renderer->render({
    filename => 'blog/hello-world',
    uri      => '/blog/hello-world',
});

cmp_ok( scalar keys $output->{ post }->%*, '>', 0, '...and gives us all the metadata in a hashref' );

is( $output->{ prototype }, 'blog', '...and a specified prototype when asked to' );

lives_ok{ $renderer->render({
    filename => 'blarg',
    uri      => '/blarg',
}) } 'We can even render with no frontmatter!';

dies_ok{ $renderer->render({ filename => 'blog/goodbye-cruel-world' }) }
    "...but won't try to render a non-existent file";

warnings_exist{ $renderer->render({ filename => 'blog/hello-world' }) }
    [ qr/Missing URI/ ],
    "...and will warn when it can't make a permalink";

my $config_no_url = LoadFile $ENV{ DANCER_CONFDIR } . "/config.yml";
delete $config_no_url->{ site }{ url };

my $questionable_renderer = Waltz::Renderer->new({ basedir => $cwd, config => $config_no_url });
throws_ok( sub { $questionable_renderer->render({ filename => 'blog/hello-world' }) },
    qr/can't make a valid URI/,
    "...and die when it can't" );

lives_ok { $renderer->render({
    filename => 'blog/hello-world.md',
    uri      => '/blog/hello-world',
}) } '...and still renders if you give the .md extension';

my $mech = Test::WWW::Mechanize::PSGI->new( app => Waltz::App->to_app );
$mech->get_ok( '/blog/hello-world', 'App returns a 200 on a valid page' );

# TODO: test output w/File::Temp
done_testing;
