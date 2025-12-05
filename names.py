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
import process
from process import echo_string,error_abort,abort_on_nonzero_env,abort_on_zero_env,abort_on_zero_keyword
from process import requirenonzero,nonnull

##
## Deescription: compute package name and version,
## both lowercase
## in the future we will handle the case of git pulls
## Result: pair package,version
##
def packagenames( **kwargs ):
    package = kwargs.get("package").lower()
    version = kwargs.get("packageversion").lower()
    terminal = kwargs.get("terminal")
    if version == "git":
        # raise Exception( "gitdate not yet implemented" )
        today = re.sub( '-','',str(datetime.date.today()) )
        version = f"git{today}"
    echo_string( f"setting internal variables packagebasename={package} packageversion={version}",
                 terminal=terminal )
    return package,version

##
## Description: create a directory for either building or install
##
def create_homedir( **kwargs ):
    root     = kwargs.get( "root",None )
    package  = kwargs.get( "package","nullpackage" )
    homedir  = kwargs.get( "homedir",None )
    terminal = kwargs.get( "terminal",None )
    package,_ = packagenames(package=package,packageversion="0.0",termminal=terminal)
    if root:
        echo_string( f"creating homedir value based on root: {root}",terminal=terminal )
        homedir = f"{root}/{package}"
    else:
        if not nonnull( homedir ): raise Exception( "need either root or homedir" )
        echo_string( f"creating homedir value based on homedir: {homedir}",terminal=terminal )
    echo_string( f"using homedir: {homedir}",terminal=terminal )
    if not os.path.isdir(homedir):
        echo_string( f"creating homedir: {homedir}",terminal=terminal )
        try:
            os.mkdir(homedir)
        except PermissionError:
            echo_string( f"ERROR: no permission to create homedir: {homedir}" )
            sys.exit(1)
    return homedir

##
## Description: compute compiler & mpi name & version
## Result: quadruple cname,cversion,mname,mversion
## Notes:
## this is fully based on Lmod environment variables as in use at TACC
##
def compiler_names():
    try:
        # in jail we can run without compiler loaded
        compiler = os.environ['TACC_FAMILY_COMPILER']
        cversion = os.environ['TACC_FAMILY_COMPILER_VERSION']
        cshortv = re.sub( r'^([^\.]*)\.([^\.]*)(\.*)?$',r'\1\2',cversion ) # DOESN'T WORK
        mpi = os.environ['TACC_FAMILY_MPI']
        mversion = os.environ['TACC_FAMILY_MPI_VERSION']
        return compiler,cversion,cshortv,mpi,mversion
    except:
        return None,None,None,None,None

##
## Description: compute single system/compiler/mpi identifier
##
def environment_code( mode ):
    systemcode = os.environ['TACC_SYSTEM'] # systemnames
    compilercode,compilerversion,compilershortversion,mpicode,mpiversion = compiler_names()
    if compilercode is None:
        # we are running in jail with only system compilers
        return systemcode
    else:
        envcode = f"{systemcode}-{compilercode}{compilerversion}"
        if mode in ["mpi","hybrid",]:
            envcode = f"{envcode}-{mpicode}{mpiversion}"
        return envcode

def systemnames():
    compilercode,compilerversion,compilershortversion,mpicode,mpiversion = compiler_names()
    return mpicode,mpiversion

def install_extension( **kwargs ):
    package,packageversion = packagenames( **kwargs )
    envcode = environment_code( kwargs.get("mode") )
    installext = f"{packageversion}-{envcode}"
    if nonnull( iext := kwargs.get( "installext","" ) ):
        installext = f"{installext}-{iext}"
    if nonnull( variant := kwargs.get("installvariant","") ):
        installext = f"{installext}-{variant}"
    return installext

def builddir_name( **kwargs ):
    package,packageversion = packagenames( **kwargs )
    installext = install_extension( **kwargs )
    if nonnull( bdir := kwargs.get("root","") ):
        builddir = f"{bdir}/build-{installext}"
    else:
        homedir = create_homedir( **kwargs )
        builddir = f"{homedir}/build-{installext}"
    return builddir

def prefixdir_name( **kwargs ):
    package,packageversion = packagenames( **kwargs )
    if nonnull( pdir:=kwargs.get("installpath","") ):
        echo_string( f"Using external prefixdir: {pdir}",terminal=None )
        prefixdir = pdir
    elif nonnull( kwargs.get("noinstall","") ):
        raise Exception( f"use of NOINSTALL not implemented" )
    else:
        # path & "installation"
        if nonnull( idir:=kwargs.get("installroot","") ):
            prefixdir = f"{idir}/installation"
        else: 
            hdir = create_homedir( **kwargs )
            prefixdir = f"{hdir}/installation"
        # attach package name
        if nonnull( mname:=kwargs.get("modulename","") ):
            prefixdir = f"{prefixdir}-{mname}"
        else:
            prefixdir = f"{prefixdir}-{package}"
        # install extension
        installext = install_extension( **kwargs )
        prefixdir = f"{prefixdir}-{installext}"
    if not nonnull( prefixdir ):
        raise Exception( "failed to set prefixdir" )
    if nonnull( var := kwargs.get("installvariant","") ):
        prefixdir = f"{prefixdir}/{var}"
    return prefixdir

def module_file_full_name( **kwargs ):
    abort_on_nonzero_env( "MODULEDIRSET" )
    #
    # construct module path
    #
    if nonnull( dirset := kwargs.get("moduledirset") ):
        # in jail we get an explicit path
        modulepath = dirset
    else:
        # otherwise we build the path from system & compiler info
        modulepath = abort_on_zero_keyword( "moduleroot",**kwargs )
        if ( mode := kwargs.get("mode","mode_not_found") ) == "core":
            modulepath += f"/Core"
        else:
            compilercode = abort_on_zero_keyword( "compiler",**kwargs )
            compilerversion = abort_on_zero_keyword( "compilerversion",**kwargs )
            if mode in [ "mpi","hybrid", ]:
                mpicode = abort_on_zero_keyword( "mpi",**kwargs )
                mpiversion = abort_on_zero_keyword( "mpiversion",**kwargs )
                modulepath += f"/MPI/{compilercode}/{compilerversion}/{mpicode}/{mpiversion}"
            elif mode in [ "seq","omp", ]:
                modulepath += f"/Compiler/{compilercode}/{compilerversion}"
            else: error_abort( f"Unknown mode: {mode}" )
    #
    # attach package name
    #
    package,packageversion = packagenames( **kwargs )
    modulename = kwargs.get( "MODULENAME",package )
    moduledir = f"{modulepath}/{modulename}"
    #
    # attach module version
    #
    moduleversion = packageversion
    if nonnull( vt := kwargs.get("installvariant") ):
        moduleversion += f"-{vt}"
    if nonnull( mx := kwargs.get("moduleversionextra") ):
        moduleversion += f"-{mx}"

    return f"{moduledir}/{moduleversion}.lua"
