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
import names
import process
from process import echo_string,error_abort,abort_on_zero_keyword
from process import nonnull,zero_keyword,nonzero_keyword

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
                    error = True
        except: continue
    if error: sys.exit(1)

def package_dir_names( **kwargs ):
    prefixdir = kwargs.get("prefixdir")
    # lib
    if zero_keyword( "nolib",**kwargs ):
        libdir = f"{prefixdir}/lib64"
        if not os.path.isdir( libdir ):
            libdir = f"{prefixdir}/lib"
            if not os.path.isdir( libdir ):
                raise Exception( "Could not find lib or lib64 dir" )
    else: libdir = ""
    # inc
    if zero_keyword( "noinc",**kwargs ):
        incdir = f"{prefixdir}/include"
        if not os.path.isdir( incdir ):
            raise Exception( "Could not find include dir" )
    else: incdir = ""
    # bin
    if nonzero_keyword( "hasbin",**kwargs ):
        bindir = f"{prefixdir}/bin"
        if not os.path.isdir( bindir ):
            raise Exception( "Could not find bin dir" )
    else: bindir = ""
    return prefixdir,libdir,incdir,bindir

def module_help_string( **kwargs ):
    package       = abort_on_zero_keyword( "package",**kwargs )
    moduleversion = abort_on_zero_keyword( "moduleversion",**kwargs )
    about         = abort_on_zero_keyword( "about",**kwargs )
    software      = kwargs.get( "softwareurl"," " )
    
    vars = f"TACC_{package.upper()}_DIR"
    for sub in [ "inc", "lib", "bin", ]:
        if dir := kwargs.get( f"{sub}dir" ):
            vars += f", TACC_{package.upper()}_{sub.upper()}"
    return \
f"""
local helpMsg = [[
Package: {package}/{moduleversion}

{about}
{software}

The {package.lower()} modulefile defines the following variables:
    {vars}.
]]
"""
