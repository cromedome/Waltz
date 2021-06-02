# Waltz
If [Hugo](https://gohugo.io) and [Middleman](https://middlemanapp.com/)
had a lovechild, Waltz would be it. Build a static blog ala Hugo, or do
some bona fide mockups like Middleman. Eventually, you can bootstrap
this into a full [Dancer2](https://perldancer.org) app. But we aren't
there yet. You're lucky there is even this. You're welcome.

## Running Waltz
If you were to serve static content out of the repo's `share/`
directory, you'd want to do the following:
```
PERL5LIB=../lib DANCER_CONFDIR=. DANCER_VIEWS=views/ ../bin/waltz dev
```
That's not a great real world example however. I will provide a better
one when I have a bona fide test repository based on Hugo content ready
to server.
