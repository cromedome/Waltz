package Waltz::Renderer;

use v5.20;
use Moo;
use strictures 2;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use Cwd;
use Template;
use Path::Tiny;
use YAML qw( Load );
use Text::Markdown 'markdown';
use Data::Printer;

has basedir => (
    is      => 'ro',
    default => sub { getcwd(); },
);

# Render a single file as markdown, return a hashref with the content and
# metadata.
sub render( $self, $args ) {
    my $filename = $args->{ filename };
    my $config   = $args->{ config };
    my $uri      = $args->{ uri };

    my $markdown_base = $self->basedir . '/content/';
    my ($file)        = $filename =~ /\.md$/ ? $filename : "${filename}.md";
    # TODO: -e file
    my $raw_content   = path( $markdown_base . $file )->slurp_utf8;
    my @page_pieces   = split( /---\n/, $raw_content ); shift @page_pieces; # First element always empty, discard it
    my $frontmatter   = Load( $page_pieces[0] );
    my $markdown      = $page_pieces[1]; chomp $markdown; $markdown =~ s/^\s+//gm;

    # TODO: Make permalink
    # TODO: Footer, disable comments locally
    return {
        prototype => $frontmatter->{ prototype } // 'default',
        title     => $frontmatter->{ title } . ' - ' . $config->{ site }{ title },
        site      => $config->{ site },
        menu      => $config->{ menu },
        post      => $frontmatter,
        author    => $config->{ author },
        widgets   => $config->{ widgets },
        output    => markdown( $markdown ),
        permalink => $uri,
    };
}

sub render_all( $self ) {
    #my $template = Template->new({ INCLUDE_PATH => [ 'views/' ]});

    ## File output
    #$template->process(
        #$page->{ page } . '.tt',
        #$vars,
        #"public/${name}.html",
    #);

    return $self->render;
}

1;

