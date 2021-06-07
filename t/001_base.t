use v5.20;
use strictures 2;

use Test::More;
use Path::Tiny;

path( 'lib' )->visit(sub {
    my ($path) = @_;
    return unless $path =~ /\.pm$/ and $path =~ s/^lib\///;
    require_ok $path or BAIL_OUT "Can't load $path";
}, { recurse => 1 });

done_testing;
