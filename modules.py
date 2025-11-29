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
        loadedversion = os.environ[ "TACC_"+mod.upper()+"_VERSION" ]
        if nonnull(ver):
            load_mjr,load_mnr,load_mcr = f"{loadedversion}.0.0".split(".",maxsplit=2)
            load_mnr = load_mnr.strip(".0")
            load_mcr = load_mcr.strip(".0")
            want_mjr,want_mnr,want_mcr = f"{ver}.99.99".split(".",maxsplit=2)
            for l,w in zip( [load_mjr,load_mnr,load_mcr],[want_mjr,want_mnr,want_mcr] ):
                if l==w or w=="99":
                    echo_string( f"module version match load={l} want={w}" )
                else:
                    echo_string( f"module version mismatch load={l} want={w}" )
    if error: sys.exit(1)
