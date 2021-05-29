package Waltz::App;

use Dancer2;
use Waltz;

get '/version' => sub {
    return "Version " . $Waltz::VERSION;
};

get '/' => sub {
    #template 'index' => { 'title' => 'Waltz' };
    return "Hello, world!";
};

true;
