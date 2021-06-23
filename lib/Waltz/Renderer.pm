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

# Don't make a template object unless we have to, but don't create it again
# if we already have one lying around.
has template => (
    is      => 'lazy',
    default => sub { my $template = Template->new({ INCLUDE_PATH => [ 'views/' ]}); }
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

    my $content = defined $data->{ _content } ? markdown( $data->{ _content } ) : '';

    return {
        post      => $data,
        prototype => $data->{ prototype } // 'default',
        title     => $title,
        output    => $content,
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

# TODO: debug mode, list files
sub render_all( $self ) {
    my %stats; # Num pages, time elapsed, cache stats, what else?

    # TODO: optionally rerender despite cache status
    # TODO: cache tags, articles we see. Write a dir/page out for all tags, and one for each
    # TODO: cache categories, articles we see. Write a dir/page out for all cats, and one for each
    # TODO: Move static content to public. Use remove_path?
    my $dir_iter = path( $self->basedir . '/content' )->iterator({ recurse => 1 });
    while( my $md_file = $dir_iter->() ) {
        my $basename = $md_file->relative( 'content' ); $basename =~ s/\.md$//g;
        next if $md_file !~ /\.md$/;

        my $output_file = 'public/';
        if( $basename =~ /index$/ ) {
            $output_file .= "${basename}.html"; 
            $output_file =~ s/_//g;
        } else {
            $output_file .= "${basename}/index.html";
        }
        say "INPUT FILENAME: $basename, OUTPUT FILENAME: $output_file";

        path( $output_file )->touchpath unless path( $output_file )->exists;

        # TODO: try/catch error checking
        my $page_data = $self->render({
            filename => $basename,
            uri      => $basename,
        });

        # TODO: render_tt method? Render to scalar, return. Use path::tiny to write to disk?
        my $config = $self->config;
        my $vars   = {
            site    => $config->{ site },
            menu    => $config->{ menu },
            author  => $config->{ author },
            widgets => $config->{ widgets },
            output  => $page_data->{ output },
        };

        my $page = $self->_render_template({
            filename => $page_data->{ prototype },
            vars     => $vars,
        });

        # Now, do the page frame. Write out to disk, do the next page.
        $vars->{ content } = $page;
        $page = $self->_render_template({
            filename => 'layouts/main', # TODO: make this frontmatter
            vars     => $vars,
        });

        path( $output_file )->spew_utf8([ $page ]);
    }

    return \%stats;
}

# Stupidly simple, but DRY.
sub _render_template( $self, $args ) {
    my $filename = $args->{ filename } . '.tt' 
        or croak "_render_template(): no template filename given!";

    my $vars = $args->{ vars } or croak "_render_template(): No content provided!";

    $self->template->process(
        $filename, 
        $vars,
        \my $page,
    );

    return $page;
}

sub BUILD {
    my $self = shift;

    my $config = $self->config;  
    croak "Renderer: missing blog configuration!" unless $config;
}

1;

