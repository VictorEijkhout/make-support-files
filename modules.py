#!/usr/bin/env/python3

#
# standard python modules
#
import datetime
import os
import re
import sys

#
# my own modules
#
import names
import process
from process import echo_string,error_abort,abort_on_zero_keyword
from process import nonnull,zero_keyword,nonzero_keyword,nonzero_keyword_or_default

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
    package       = abort_on_zero_keyword( "package",**kwargs ).lower()
    moduleversion = abort_on_zero_keyword( "moduleversion",**kwargs )
    about         = abort_on_zero_keyword( "about",**kwargs )
    software      = kwargs.get( "softwareurl"," " )
    cmake         = kwargs.get( "prefixpathset" )
    pkgconfig     = kwargs.get( "pkgconfig" )

    vars = f"TACC_{package.upper()}_DIR"
    for sub in [ "inc", "lib", "bin", ]:
        if dir := kwargs.get( f"{sub}dir" ):
            vars += f", TACC_{package.upper()}_{sub.upper()}"
    notes = ""
    if cmake    : notes += "Discoverable by CMake through find_package.\n"
    if pkgconfig: notes += "Discoverable by CMake through pkg-config.\n"
    notes += f"\n(modulefile generated {datetime.date.today()})"

    return \
f"""\
local helpMsg = [[
Package: {package}/{moduleversion}

{about}
{software}

The {package} modulefile defines the following variables:
    {vars}.

{notes}
]]
""".strip()

def package_info( **kwargs ):
    package       = abort_on_zero_keyword( "package",**kwargs ).lower()
    moduleversion = abort_on_zero_keyword( "moduleversion",**kwargs )
    return \
f"""\
whatis( "Name:",   \"{package}\" )
whatis( "Version", \"{moduleversion}\" )
""".strip()

def path_settings( **kwargs ):
    packagename   = abort_on_zero_keyword( "package",**kwargs ).lower()
    modulename    = nonzero_keyword_or_default( "modulename",default=packagename ).lower()
    modulenamealt = kwargs.get("modulenamealt","").lower()
    moduleversion = abort_on_zero_keyword( "moduleversion",**kwargs )
    prefixdir     = abort_on_zero_keyword( "prefixdir",**kwargs ).strip("/")

    paths = ""
    info  = ""
    for name in [ modulename, modulenamealt, ]:
        if name=="": continue
        for sub,val in [ ["VERSION",f"\"{moduleversion}\""], ["DIR","prefixdir"], ]:
            for tgt in [ "TACC", "LMOD", ] :
                info += f"setenv( \"{tgt}_{name.upper()}_{sub.upper()}\", {val} )\n"
        for sub in [ "inc", "lib", "bin", ]:
            if dir := kwargs.get( f"{sub}dir" ):
                ext = re.sub( f"{prefixdir}/","",dir ).lstrip("/") # why the lstrip?
                for tgt in [ "TACC", "LMOD", ] :
                    paths += f"setenv( \"{tgt}_{name.upper()}_{sub.upper()}\", \
pathJoin( prefixdir,\"{ext}\" ) )\n"

    return \
f"""\
local prefixdir = \"{prefixdir}\"
{info}{paths}
""".strip()

def system_paths( **kwargs ):
    packagename   = abort_on_zero_keyword( "package",**kwargs ).lower()
    modulename    = nonzero_keyword_or_default( "modulename",default=packagename ).lower()
    modulenamealt = kwargs.get("modulenamealt","").lower()
    moduleversion = abort_on_zero_keyword( "moduleversion",**kwargs )
    prefixdir     = abort_on_zero_keyword( "prefixdir",**kwargs ).strip("/")

    envs = ""
    for sub in [ "inc", "lib", "bin", ]:
        if dir := kwargs.get( f"{sub}dir" ):
            ext = re.sub( f"{prefixdir}/","",dir ).lstrip("/") # why the lstrip?
            path = f"pathJoin( prefixdir,\"{ext}\" )"
            if sub=="inc":
                envs += f"prepend_path( \"INCLUDE\", {path} )\n"
            elif sub=="lib":
                envs += f"prepend_path( \"LD_LIBRARY_PATH\", {path} )\n"
            elif sub=="bin":
                envs += f"prepend_path( \"PATH\", {path} )\n"
    for env,var in [ ["bindir","PATH"],
                 ["pkgconfig","PKG_CONFIG_PATH"], ["pkgconfiglib","PKG_CONFIG_PATH"],
                 [ "cmakeprefix","CMAKE_PREFIX_PATH"],
                 ["pythonpathabs","PYTHONPATH"], ["pythonpathrel","PYTHONPATH"],
                ]:
        if val := nonzero_keyword( env,**kwargs ):
            if env in [ "bindir", "pkgconfig", "pkgconfiglib", "pythonpathrel",
                       ]:
                #
                # add path relative to prefix
                #
                if env in [ "bindir", "pkgconfiglib", ]:
                    # relative to prefix & standard extension
                    val = re.sub( f"{prefixdir}/","",val ).lstrip("/") # why the lstrip?
                    # else relative to prefix & custom path
                path = f"pathJoin( prefixdir,\"{val}\" )"
                envs += f"prepend_path( \"{var}\", {path} )\n"
            elif env in [ "cmakeprefix",
                         ]:
                #
                # add prefix path itself
                #
                envs += f"prepend_path( \"{var}\", prefixdir )\n"
            elif env in [ "pythonpathabs", ]:
                #
                # add absolute path
                #
                envs += f"prepend_path( \"{var}\", \"{val}\" )\n"

    return \
f"""\
{envs}
""".strip()
