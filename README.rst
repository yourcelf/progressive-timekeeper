Progressive Timekeeper
======================

This is a simple application for "progressive timekeeping" –
keeping track of speaking time by categories of identity (e.g. sex, gender,
racial identity, power position, etc). It can be used to help people think
about whether or not speaking time in their organization's meetings is in fact
equitable.

To use, set up the categories you'd like to track in the settings. Then, press
the button when someone identifying with that category speaks, and press it
again when they finish. Multiple categories can be activated at once. This app
can run on a phone or laptop, and could be part of the role of a timekeeper,
alongside facilitators or stack keepers.

Inspired by this `visualization by numeroteca <http://numeroteca.org/2012/01/11/interventions-occupyboston-ga-jan-10th-2012/>`_.

Please send feedback, suggestions, or ideas to cfd@media.mit.edu or @cdetar. 

Running server
--------------

Find this application running here: http://time.byconsens.us.  

Installation of server
----------------------

This app runs on Node v0.6.x, and is written primarily in coffeescript.

Clone the repository locally.  In the repository directory, install node
dependencies listed in `requirements.txt`.  You can do this manually, or with a
little command-line-fu::

    $ for line in `cat requirements.txt` ; do npm install "$line" ; done

Make sure coffee-script is installed globally, so we get access to the `cake`
command::

    $ npm install -g coffee-script

Run the server with::

    $ cake runserver

The server is now running on localhost on port 8000.  Or specify the port::

    $ cake --port 8001 runserver

Currently, it's deployed on Node for convenience of asset compilation; it's
essentially a static app.  The main business for this app lives in the
following files::

    lib/server.coffee           <-- ultra-simple node server for compilation
    assets/js/frontend.coffee   <-- backbone.js based user interface
    views/index.jade            <-- templates
    assets/css/style.stylus     <-- styles


License
-------

Copyright (c) 2012 Charlie DeTar

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

