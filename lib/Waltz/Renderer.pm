package Waltz::Renderer;

use v5.20;
use Moo;
use strictures 2;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use Feature::Compat::Try;
use Cwd;
use URI;
use Carp qw( carp croak );
use Template;
use Path::Tiny;
use File::Serialize { pretty => 1 };
use Text::Markdown qw( markdown );
use Data::Printer;

# The goal here is to pigeon hole us into our site content directory. I am not
# sure yet about letting a user specify what directory they want content to
# come from. Seems a bit dangerous. 
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
    # TODO: check for page in cache and if cached page is valid
    my $filename      = $args->{ filename } or croak "render(): need a filename to render!";
    my $markdown_base = $self->basedir . '/content/';
    my $file          = $markdown_base . ( $filename =~ /\.md$/ ? $filename : "${filename}.md" );
    my $data          = deserialize_file $file, { format => 'markdown' } 
        or croak "render(): File $file not found!";

    # TODO: Update page in cache
    my $title = $data->{ title } // '';
    $title = ( $title eq '' ? '' : ' - ') . $self->config->{ site }{ title };

    return {
        post      => $data,
        prototype => $data->{ prototype } // 'default',
        title     => $title,
        output    => markdown( $data->{ _content } ),
        permalink => $self->permalink( $args->{ uri }),
    };
}

sub permalink( $self, $path ) {
    carp "permalink(): Missing URI, can't generate permalink!" unless $path;

    my $uri = do{
        try {
            URI->new_abs( $path, $self->config->{ site }{ url } );
        } catch( $e ) {
            croak "permalink: can't make a valid URI!" if $e =~ /Missing base argument/;
        }
    }; 

    return $uri->as_string;
}

sub render_all( $self ) {
    my $template = Template->new({ INCLUDE_PATH => [ 'views/' ]});
    my %stats; # Num pages, time elapsed, cache stats, what else?

    # TODO: optionally rerender despite cache status
    # TODO: cache tags, articles we see. Write a dir/page out for all tags, and one for each
    # TODO: cache categories, articles we see. Write a dir/page out for all cats, and one for each
    # TODO: Move static content to public. Use remove_path?
    my $dir_iter = path( $self->basedir . '/content' )->iterator({ recurse => 1 });
    while( my $md_file = $dir_iter->() ) {
        # TODO: _index.md
        my $basename = $md_file->relative( 'content' ); $basename =~ s/\.md$//g;
        next if $md_file !~ /\.md$/;

        my $output_file = "public/${basename}.html";
        say "INPUT FILENAME: $basename, OUTPUT FILENAME: $output_file";

        path( $output_file )->touchpath unless path( $output_file )->exists;

        # TODO: try/catch error checking
        # TODO: split dir from filename
        my $page_data = $self->render({
            filename => $basename,
            uri      => $basename,
        });
        
        my $vars = {};

        #my $page;
        #$template->process(
            #$page_data->{ prototype } . '.tt',
            #$vars,
            #\$page,
        #);

        ## Now, do the page frame. Write out to disk, do the next page.
        #$vars->{ content } = $page;
        #$template->process(
            #$page->{ page } . '.tt', # TODO: Fix this
            #$vars,
            #$output_file,
        #);
    }

    return \%stats;
}

sub BUILD {
    my $self = shift;

    my $config = $self->config;  
    croak "Renderer: missing blog configuration!" unless $config;
}

1;

