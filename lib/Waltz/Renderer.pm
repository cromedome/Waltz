package Waltz::Renderer;

use v5.20;
use strictures 2;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Moo;
use Cwd;
use Path::Tiny;
use YAML qw( Load );
use Text::Markdown 'markdown';
use Template;

has basedir => (
    is => 'ro',
    default => sub { getcwd(); },
);

sub render( $filename ) {
    my $template = Template->new({ INCLUDE_PATH => [ 'templates/', 'views/' ]});

    my $cwd  = getcwd;
    my $base = "$cwd/content/";
    my $file = "${filename}.md";
    my $text = path( $base . $file )->slurp_utf8;
    my @data = split( /---\n/, $text ); shift @data;
    my $yaml = Load( $data[0] );
    my $md   = $data[1]; chomp $md; $md =~ s/^\s+//gm;

    # TODO: Make permalink
    # TODO: Footer, disable comments locally
    # TODO: configurable prototype
    # TODO: set page title
    template 'blog', { 
        site      => config->{ site },
        menu      => config->{ menu },
        post      => $yaml,
        author    => config->{ author },
        widgets   => config->{ widgets },
        output    => markdown( $data[1] ),
        permalink => request->uri,
    };

    # File output
    $template->process(
        $page->{ page } . '.tt',
        $vars,
        "public/${name}.html",
    );

    # Scalar output
    $template->process(
        'calendar_script.tt', {
            events => \@calendar_events,
        },
        \my $script,
    );
};

1;

