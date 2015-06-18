Heroku buildpack: TeX
=====================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks)
for working with TeX documents. In its raw form, it simply bundles a working
TeX Live environment into your Heroku app and doesn't do anything else with it.


    $ ls

    $ heroku create --buildpack git://github.com/holiture/heroku-buildpack-tex.git

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom build pack... done
    -----> TeX app detected
    -----> Fetching TeX Live 20120511
    ...

This can be useful if you simply want to play around with TeX Live without
having to build or install it yourself. You can pull it up on your instance
easily in bash:

    $ heroku run bash


Which TeXLive?
--------------

This buildpack allow to install multiple variants of TeX Live.
Those are built with the `built.sh` script, and uploaded to S3.

| Version       | Collections                     | Added packages            | Removed packages      |
|---------------|---------------------------------|---------------------------|-----------------------|
| `20150411-p2` | basic, latex, latexrec, xetex   | eurosym, tabto-ltx, vntex | amsfonts, koma-script |
| `20150617-p0` | basic, latex, latexrec, xetex   | eurosym, tabto-ltx, vntex | amsfonts, koma-script |

The **default** version is currently `20150411-p2`.


Installing locally
------------------

It can be useful to run the exact same binaries locally (or for instance, on a
CI server).

The `install.sh` script is hosted with the buildpack binaries; to install, just

    curl -skL https://goo.gl/FR7t9V | bash

This will by default install the current version to `./vendor/texlive`.
You can specify a particular version or prefix:

    curl -skL https://goo.gl/FR7t9V | bass -s -- -v 20150411-p0 -p /opt/texlive



Multipacks
----------

More likely, you'll want to use it as part of a larger project, which needs to
build PDFs. The easiest way to do this is with a [multipack](https://github.com/ddollar/heroku-buildpack-multi),
where this is just one of the buildpacks you'll be working with.

    $ cat .buildpacks
    git://github.com/heroku/heroku-buildpack-python.git
    git://github.com/holiture/heroku-buildpack-tex.git

    $ heroku config:add BUILDPACK_URL=git://github.com/ddollar/heroku-buildpack-multi.git

This will bundle TeX Live into your instance without impacting your existing
system. You can then call out to executables like `pdflatex` as you would on
any other machine.

