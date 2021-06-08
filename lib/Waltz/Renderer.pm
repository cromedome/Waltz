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
use File::Serialize { pretty => 1 };
use Text::Markdown qw( markdown );
use Data::Printer;

has basedir => (
    is      => 'ro',
    default => sub { getcwd(); },
);

has config => (
    is      => 'ro',
    default => sub{ return {} },
);

# Render a single file as markdown, return a hashref with the content and
# metadata.
sub render( $self, $args ) {
    my $config = $args->{ config } // $self->config;  
    croak "render(): missing blog configuration!" unless $config;

    my $filename      = $args->{ filename } or croak "render(): need a filename to render!";
    my $markdown_base = $self->basedir . '/content/';
    my $file          = $markdown_base . ( $filename =~ /\.md$/ ? $filename : "${filename}.md" );
    my $data          = deserialize_file $file, { format => 'markdown' } 
        or croak "render(): File $file not found!";

    return {
        post      => $data,
        prototype => $data->{ prototype } // 'default',
        title     => $data->{ title } . ' - ' . $config->{ site }{ title },
        output    => markdown( $data->{ _content } ),
        permalink => $self->permalink( $args->{ uri }),
    };
}

sub permalink( $self, $path ) {
    my $uri = URI->new_abs( $path, $self->config->{ site }{ url } )
        or carp "permalink(): Missing URI, can't generate permalink!";
    return $uri->as_string;
}

sub render_all( $self ) {
    #my $template = Template->new({ INCLUDE_PATH => [ 'views/' ]});

    # TODO: cache tags, articles we see. Write a dir/page out for all tags, and one for each
    # TODO: cache categories, articles we see. Write a dir/page out for all cats, and one for each
    ## File output
    #$template->process(
        #$page->{ page } . '.tt',
        #$vars,
        #"public/${name}.html",
    #);

    return $self->render;
}

1;

