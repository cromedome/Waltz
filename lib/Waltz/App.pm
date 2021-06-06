package Waltz::App;

use v5.20;
use Dancer2;
use strictures 2;
no warnings qw( experimental::signatures );
use feature qw( signatures );

use Cwd;
use Feature::Compat::Try;
use Waltz;
use Waltz::Renderer;
use Data::Printer;

# TODO: Template::AutoFilter

# The goal here is to pigeon hole us into our site content directory. I am not
# sure yet about letting a user specify what directory they want content to
# come from. Seems a bit dangerous. 
#set appdir => '/Users/jason/src/Waltz/app/share/';
#set confdir => '/Users/jason/src/Waltz/app/share/';
#set views => '/Users/jason/src/Waltz/app/share/views';
#set public_dir => '/Users/jason/src/Waltz/app/share/static';
#set static_handler => true;

state $renderer;
prepare_app {
    my $cwd = getcwd; 
    say "Waltzing in $cwd...";

    $renderer = Waltz::Renderer->new({ basedir => $cwd, config => config });

    my @files = $_[0]->config_files->@*;
    say 'Watching ' . join( ',', @files ) . ' for file updates.';
};

# These next few routes seem good for development, not sure if they will stick
# around for the long haul.
get '/version' => sub { return 'Version ' . $Waltz::VERSION; };

get '/settings' => sub {
    my @views  = setting( 'views' );
    my @public = setting( 'public_dir' );
    return 'Settings:<br>' .
        'Views: ' . join( ', ', setting 'views' ) . '<br>' . 
        'Static dir: ' . join( ', ', setting 'public_dir' );
};

get '/' => sub {
    template 'index' => { 'title' => 'Waltz' };
};

# Here's the crux of the development server app. Look for a markdown file
# with the name and relative path provided, parse the metadata, render 
# the markdown as HTML, and wrap it all in our layout and templating 
# engine.
get '/**' => sub {
    my( $route ) = splat;

    my $page = do{
        try {
            $renderer->render({
                uri      => request->uri,
                filename => join( '/', $route->@* ),
            });
        } catch( $e ) {
            error $e;
            if( $e =~ /^render.+not found!/ ) {
                status 'not_found';
                return;
            } else {
                die $e;
            }
        }
    };
    template $page->{ prototype }, $page;
};

true;
