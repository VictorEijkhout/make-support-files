#!/usr/bin/env/python3

#
# standard python modules
#
import os
import re
import sys

#
# my own modules
#
import process
from process import echo_string,requirenonzero,nonnull

def test_modules( **kwargs ):
    modules = kwargs.get( "modules","" )
    error = False
    for m in modules.split(" "):
        if not nonnull(m):continue
        mod,ver = f"{m}/".split('/',maxsplit=1); ver=ver.strip("/")
        echo_string( f"test presence of module={mod} version={ver}" )
        try:
            dir = os.environ[ "TACC_"+mod.upper()+"_DIR" ]
        except:
            error = True
            echo_string( f"Please load module: {mod}" )
            continue
        if not os.path.isdir(dir):
            error = True
            echo_string( f"Module {mod} loaded but directory not found: {dir}" )
        try:
            loadedversion = os.environ[ "TACC_"+mod.upper()+"_VERSION" ]
            if nonnull(ver):
                if not process.version_satisfies(loadedversion,ver,terminal=None):
                    echo_string( f"loaded version: {loadedversion} does not match version {ver}" )
        except: continue
    if error: sys.exit(1)
