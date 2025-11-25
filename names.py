#!/usr/bin/env/python3

#
# standard python modules
#
import os
import re

#
# my own modules
#
import process
from process import echo_string,requirenonzero
# requirenonzeropath

def packagenames( package,version,gitdate=None ):
    package = package.lower()
    version = version.lower()
    if version == "git":
        raise Exception( "gitdate not yet implemented" )
    echo_string( f"setting internal variables packagebasename={package} packageversion={version}" )
    return package,version

def create_homedir( **kwargs ):
    system   = kwargs.get("system",None)
    compiler = kwargs.get("compiler",None)
    root     = kwargs.get("root",None)
    package  = kwargs.get("package","nullpackage")
    version  = kwargs.get("version","0.0.0")
    homedir  = kwargs.get("homedir",None )
    requirenonzero(system)
    requirenonzero(compiler)
    requirenonzero(root)
    echo_string( f"computing homedir value based on root: {root}" )
    package,version = packagenames(package,version)
    if not homedir:
        home = f"{root}/{package}"
    echo_string( f"using homedir: {home}" )
    if not os.path.isdir(home):
        echo_string( f"creating homedir: {home}" )
        os.mkdir(home)
    return home
