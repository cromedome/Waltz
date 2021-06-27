use v5.20;
use strictures 2;
use Test::More;
use Waltz;

like $Waltz::VERSION, qr/^\d+\.\d+\.\d+$/, "Got a valid version number.";

done_testing;
