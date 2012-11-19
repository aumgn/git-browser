Git Browser
============

Git Browser is a lightweight yet fancy web git repository viewer.
It is basically a quick port of [gitlist][1] (meaning it uses almost exactly
the same html/js/css base) from php/silex/twig/gitter to
ruby/sinatra/mustache/grit for those like me who love hacking on the tools
they use but can't bear php.


Installation
-------------
Assuming you know a bit about ruby :

Clone the repository :

```
git clone git://github.com/aumgn/git-browser
```

Copy the sample config and edit it :

```
cp app/conf/config.example.yml app/conf/config.yml
$EDITOR app/conf/config.yml
```

Install dependencies :

```
bundle install
# or :
bundle install --without rugged # If you don't want to use rugged
```

Compile the stylesheet (requires [less][2]) :

```
rake style
```

Fire your favorite server :

```
thin
puma
other_weird_ruby_server_name
```

Notes
------

### Git Backends :

Git Browser has been designed to allow use of differents git backend.
Right now [grit][3] and [rugged][4] (only partially, it delegates everything
not implemented to grit, but still offers a notable performance boost
especially for larger projects) are supported.

### JRuby :

JRuby is not really supported, because both grit and rugged rely on
C-extensions. One solution for the future would be to implement a backend
using [jgit][5].

Thanks
--------

Special thanks to [Klaus Silveira][6] and the others contributors for gitlist
without which Git Browser wouldn't probably exists.


License
--------
Released under MIT License. See [LICENSE][7] file.


[1]: http://gitlist.org/
[2]: http://lesscss.org/
[3]: https://github.com/mojombo/grit
[4]: https://github.com/libgit2/rugged
[5]: http://eclipse.org/jgit/
[6]: https://github.com/klaussilveira
[7]: http://github.com/aumgn/git-browser/blob/master/LICENSE
