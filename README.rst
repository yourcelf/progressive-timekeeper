Progressive Timekeeper
======================

This is a simple application with which one can do "progressive timekeeping" – keeping track of speaking time by categories of identity (e.g. sex, gender, racial identity, power position, etc). It can be used to help people think about whether or not speaking time in their organization's meetings are in fact equitable.

To use, set up the categories you'd like to track in the settings. Then, press the button when someone identifying with that category speaks, and press it again when they finish. Multiple categories can be activated at once. This app can run on a phone or laptop, and could be part of the role of a timekeeper, alongside facilitators or stack keepers.

Please send feedback, suggestions, or ideas to cfd@media.mit.edu or @cdetar. 

Running server
--------------

Find this application running here: http://time.byconsens.us.  

Installation of server
----------------------

This app runs on Node v0.6.x, and is written primarily in coffeescript.

Clone the repository locally.  In the repository directory, install node dependencies listed in `requirements.txt`.  You can do this manually, or with a little command-line-fu:

    $ for line in `cat requirements.txt` ; do npm install "$line" ; done

Make sure coffee-script is installed globally, so we get access to the `cake` command:

    $ npm install -g coffee-script

Run the server with:

    $ cake runserver

The server is now running on localhost on port 8000.  Or specify the port:

    $ cake --port 8001 runserver
