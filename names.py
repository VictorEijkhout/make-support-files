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
# requirenonzeropath

def packagenames( package,version,gitdate=None,terminal=sys.stdout ):
    package = package.lower()
    version = version.lower()
    if version == "git":
        raise Exception( "gitdate not yet implemented" )
    echo_string( f"setting internal variables packagebasename={package} packageversion={version}",
                 terminal=terminal )
    return package,version

def create_homedir( **kwargs ):
    root     = kwargs.get("root",None)
    package  = kwargs.get("package","nullpackage")
    homedir  = kwargs.get("homedir",None )
    requirenonzero(root)
    echo_string( f"computing homedir value based on root: {root}" )
    package,_ = packagenames(package,"0,0")
    if not homedir:
        home = f"{root}/{package}"
    echo_string( f"using homedir: {home}" )
    if not os.path.isdir(home):
        echo_string( f"creating homedir: {home}" )
        os.mkdir(home)
    return home

def compiler_names():
    compiler = os.environ['TACC_FAMILY_COMPILER']
    cversion = os.environ['TACC_FAMILY_COMPILER_VERSION']
    cshortv = re.sub( r'^([^\.]*)\.([^\.]*)(\.*)?$',r'\1\2',cversion ) # DOESN'T WORK
    mpi = os.environ['TACC_FAMILY_MPI']
    mversion = os.environ['TACC_FAMILY_MPI_VERSION']
    return compiler,cversion,cshortv,mpi,mversion
def environment_code( mode ):
    systemcode = os.environ['TACC_SYSTEM'] # systemnames
    compilercode,compilerversion,compilershortversion,mpicode,mpiversion = compiler_names()
    envcode = f"{systemcode}-{compilercode}{compilerversion}"
    if mode=="mpi":
        envcode = f"{envcode}-{mpicode}{mpiversion}"
    return envcode
def systemnames():
    compilercode,compilerversion,compilershortversion,mpicode,mpiversion = compiler_names()
    return mpicode,mpiversion

def install_extension( **kwargs ):
    package,packageversion = packagenames\
        ( kwargs.get("package"),kwargs.get("packageversion"),
          terminal=kwargs.get("terminal",None) )
    envcode = environment_code( kwargs.get("mode") )
    installext = f"{packageversion}-{envcode}"
    if nonnull( iext := kwargs.get( "installext","" ) ):
        installext = f"{installext}-{iext}"
    if nonnull( variant := kwargs.get("installvariant","") ):
        installext = f"{installext}-{variant}"
    return installext

def prefixdir_name( **kwargs ):
    prefixdir = ""
    package,packageversion = packagenames\
        ( kwargs.get("package"),kwargs.get("packageversion"),
          terminal=kwargs.get("terminal",None) )
    if nonnull( prefixdir:=kwargs.get("installpath","") ):
        echo_string( f"Using external prefixdir: {prefixdir}" )
    elif nonnull( kwargs.get("noinstall","") ):
        raise Exception( f"use of NOINSTALL not implemented" )
    else:
        # path & "installation"
        if nonnull( idir:=kwargs.get("installroot","") ):
            prefixdir = f"{idir}/installation"
        else: 
            hdir = create_homedir( **kwargs );
            prefixdir = f"{hdir}/installation"
        # attach package name
        if nonnull( mname:=kwargs.get("modulename","") ):
            prefixdir = f"{prefixdir}-{mname}"
        else:
            prefixdir = f"{prefixdir}-{package}"
        # install extension
        installext = install_extension \
            ( package=package,packageversion=packageversion,
              installext=kwargs.get("installext",""),installvariant=kwargs.get("installvariant",""),
              mode=kwargs.get("mode"),
            )
        prefixdir = f"{prefixdir}-{installext}"
    if not nonnull( prefixdir ):
        raise Exception( "failed to set prefixdir" )
    if nonnull( var := kwargs.get("installvariant","") ):
        prefixdir = f"{prefixdir}/{var}"
    return prefixdir
