import os
import time
import signal
import subprocess
from fabric.api import *
"""
This is a simple build script to deploy this app as a static html site.

To use: 
    1. Install fabric: http://fabfile.org
    2. With node 0.6.x and all dependencies all set up, run:

        $ fab deploy -H example.com

    ... where example.com is the destination server.  This will place the files
    in the directory /sites/time.byconsens.us/.  To change this, run:

        $ fab deploy:dest="/var/www/somedir" -H example.com

    Set the username for the remote server with "--user", defaults to your
    current logged in username.

The script operates by starting node in production mode, spidering the site
with wget, and deploying with rsync.  As a bonus, it builds an appcache
manifest file for offline use.
"""

BUILD_DIR = os.path.join(os.path.dirname(__file__), "_build")

def deploy(branch="master", dest='/sites/time.byconsens.us'):
    """
    Deploy the local tree to master.  Do your own git committing first.
    """

    # Fire up server in production mode.
    proc = subprocess.Popen("NODE_ENV=production cake --port 8001 runserver",
            shell=True,
            preexec_fn=os.setsid)
    try:
        time.sleep(1) # give node a second to launch...

        # Spider the site.
        with settings(warn_only=True):
            local("rm -r \"%s\"" % BUILD_DIR)
        local("mkdir -p %s" % BUILD_DIR)
        with lcd(BUILD_DIR):
            local("wget -nH --mirror --page-requisites http://localhost:8001")

        # Build appcache manifest.
        manifest = os.path.join(BUILD_DIR, "appcache.manifest")
        with open(manifest, 'w') as fh:
            fh.write("CACHE MANIFEST\n")
            for root, dirs, files in os.walk(BUILD_DIR):
                for filename in files:
                    path = os.path.join(root, filename)
                    if path != manifest:
                        rel_path = os.path.relpath(path, BUILD_DIR)
                        fh.write(rel_path + "\n")
        local("cat %s" % manifest)

        # Deploy with rsync.
        local("rsync -az --delete %s %s@%s:%s" % (
            BUILD_DIR.rstrip("/") + "/",
            env.user,
            env.host,
            dest.rstrip("/") + "/",
        ))
    finally:
        os.killpg(proc.pid, signal.SIGTERM)
