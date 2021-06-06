package Waltz::Renderer;

use v5.20;
use Moo;
use strictures 2;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use Cwd;
use URI;
use Carp qw( carp croak );
use Template;
use Path::Tiny;
use YAML qw( Load );
use Text::Markdown 'markdown';
use Data::Printer;

has basedir => (
    is      => 'ro',
    default => sub { getcwd(); },
);

has config => (
    is      => 'ro',
    default => {},
);

# Render a single file as markdown, return a hashref with the content and
# metadata.
sub render( $self, $args ) {
    my $filename = $args->{ filename } or croak "render(): need a filename to render!";

    my $config   = $args->{ config }   or croak "render(): missing blog configuration!";
    # TODO: check for existing config, then one passed

    my $uri      = $args->{ uri }      or carp  "render(): Missing URI, can't generate permalink!";
    
    my $markdown_base = $self->basedir . '/content/';
    my ($file)        = $filename =~ /\.md$/ ? $filename : "${filename}.md";
    $file             = "$markdown_base$file";
    croak "render(): File $file not found!" unless -e $file;

    my $raw_content   = path( $file )->slurp_utf8;
    my @page_pieces   = split( /---\n/, $raw_content ); shift @page_pieces; # First element always empty, discard it
    my $frontmatter   = Load( $page_pieces[0] );
    my $markdown      = $page_pieces[1]; chomp $markdown; $markdown =~ s/^\s+//gm;

    # TODO: Make permalink
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

sub permalink( $self, $path ) {
    # TODO: config check
    # TODO: valid site base
    # TODO: valid URI
    # TODO: Move missing check here
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

