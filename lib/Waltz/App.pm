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

# TODO: Template::AutoFilter

# The goal here is to pigeon hole us into our site content directory. I am not
# sure yet about letting a user specify what directory they want content to
# come from. Seems a bit dangerous. 
#set appdir => '/Users/jason/src/Waltz/app/share/';
#set confdir => '/Users/jason/src/Waltz/app/share/';
#set views => '/Users/jason/src/Waltz/app/share/views';
#set public_dir => '/Users/jason/src/Waltz/app/share/static';
#set static_handler => true;

# Don't create the renderer any more than we have to. It's not that expensive, 
# but still... why? If we need to communicate anything to the user at runtime,
# this is a good place to do it.
state $renderer;
prepare_app {
    my $cwd = getcwd; 
    say "Waltzing in $cwd...";

    $renderer = Waltz::Renderer->new({ basedir => $cwd, config => config });

    my @files = $_[0]->config_files->@*;
    say 'Watching ' . join( ',', @files ) . ' for file updates.';
};

# This seems good for development, not sure if it will stick around for the long haul.
get '/version' => sub { return 'Version ' . $Waltz::VERSION; };

# If we hit the root of the site, make sure we try to render some content. 
# Unfortunately without this the static renderer will attempt to render
# something and won't find it, resulting in a 404.
get '/' => sub { forward '/index'; };

# Here's the crux of the development server app. Try to render a markdown
# file using the path and filename provided as HTML, and wrap it all in
# our layout and templating engine.
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
