use v5.20;
use strictures 2;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Cwd;
use YAML qw( Load );

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir 't' unless $cwd =~ /t$/;
    $ENV{ DANCER_VIEWS   } = "$cwd/views";
    $ENV{ DANCER_CONFDIR } = $cwd;
    #$ENV{ DANCER_PUBLIC } = "$cwd/views";
}

use Waltz::Renderer;

# Render fails with no config
#my $no_config_render = Waltz::Renderer
# Default prototype
# Different prototypes
# render a valid file
# file in subdir
# don't double .md on the end
# 404 on invalid file
# test renderer for valid file
# test for invalid file
# test output w/File::Temp
# Test for valid markdown w/frontmatter (good and bad)
# tags, dates, categories

done_testing;
