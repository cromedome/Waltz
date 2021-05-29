package Waltz::App;

use Dancer2;
use strictures 2;
use experimental 'signatures';
use Path::Tiny;
use Text::Markdown 'markdown';
use Waltz;

use Data::Printer;

get '/version' => sub {
    return "Version " . $Waltz::VERSION;
};

get '/' => sub {
    #template 'index' => { 'title' => 'Waltz' };
    return "Hello, world!";
};

get '/**' => sub {
    my( $route ) = splat;
    my $base = '/Users/jason/src/Waltz/test.cromedome.blog/content/';
    my $file = join( '/', $route->@* ) . '.md';
    my $text = path( $base . $file )->slurp_utf8;
    return markdown( $text );
};

true;
