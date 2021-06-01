package Waltz::App;

use Dancer2;
use strictures 2;
use experimental 'signatures';

use Cwd;
use Path::Tiny;
use Text::Markdown 'markdown';
use Waltz;
use Data::Printer;

# The goal here is to pigeon hole us into our site content directory. I am not
# sure yet about letting a user spefify what directory they want content to
# come from. Seems a bit dangerous. 
#BEGIN {
    #my $cwd = getcwd; 
    #debug "CWD IS $cwd";
    
    #$ENV{ DANCER_CONFDIR } = $cwd;
    #$ENV{ DANCER_VIEWS   } = "$cwd/views";

    ## This needs to change when we go to publish. Then again, maybe not. TBD.
    #$ENV{ DANCER_PUBLIC } = "$cwd/static";
#}

# This seems good for development, not sure if it will stick around for the
# long haul.
get '/version' => sub { return 'Version ' . $Waltz::VERSION; };

get '/settings' => sub {
    debug "VIEWS ARE " . $ENV{ DANCER_VIEWS };
    my @views = setting( 'views' ); p @views;
    my @public = setting( 'public_dir' ); p @public;
    return 'Settings:<br>' .
        'Views: ' . setting 'views',
        'Static dir: ' . setting 'public_dir';
};

get '/' => sub {
    template 'index' => { 'title' => 'Waltz' };
};

get '/**' => sub {
    my( $route ) = splat;
    my $base = '/Users/jason/src/Waltz/test.cromedome.blog/content/';
    my $file = join( '/', $route->@* ) . '.md';
    my $text = path( $base . $file )->slurp_utf8;
    return markdown( $text );
};

true;
