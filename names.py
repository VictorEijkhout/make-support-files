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

def packagenames( **kwargs ):
    package = kwargs.get("package").lower()
    version = kwargs.get("packageversion").lower()
    terminal = kwargs.get("terminal")
    if version == "git":
        raise Exception( "gitdate not yet implemented" )
    echo_string( f"setting internal variables packagebasename={package} packageversion={version}",
                 terminal=terminal )
    return package,version

def create_homedir( **kwargs ):
    root     = kwargs.get( "root",None )
    package  = kwargs.get( "package","nullpackage" )
    homedir  = kwargs.get( "homedir",None )
    terminal = kwargs.get( "terminal",None )
    requirenonzero(root)
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
    if mode in ["mpi","hybrid",]:
        envcode = f"{envcode}-{mpicode}{mpiversion}"
    return envcode

def systemnames():
    compilercode,compilerversion,compilershortversion,mpicode,mpiversion = compiler_names()
    return mpicode,mpiversion

def install_extension( **kwargs ):
    package,packageversion = packagenames( **kwargs )
        # ( kwargs.get("package"),kwargs.get("packageversion"),
        #   terminal=kwargs.get("terminal",None) )
    envcode = environment_code( kwargs.get("mode") )
    installext = f"{packageversion}-{envcode}"
    if nonnull( iext := kwargs.get( "installext","" ) ):
        installext = f"{installext}-{iext}"
    if nonnull( variant := kwargs.get("installvariant","") ):
        installext = f"{installext}-{variant}"
    return installext

def builddir_name( **kwargs ):
    package,packageversion = packagenames( **kwargs )
        # ( kwargs.get("package"),kwargs.get("packageversion"),
        #   terminal=kwargs.get("terminal",None) )
    installext = install_extension( **kwargs )
    if nonnull( bdir := kwargs.get("root","") ):
        builddir = f"{bdir}/build-{installext}"
    else:
        homedir = create_homedir( **kwargs )
        builddir = f"{homedir}/build-{installext}"
    return builddir

def prefixdir_name( **kwargs ):
    package,packageversion = packagenames( **kwargs )
        # ( kwargs.get("package"),kwargs.get("packageversion"),
        #   terminal=kwargs.get("terminal",None) )
    if nonnull( pdir:=kwargs.get("installpath","") ):
        echo_string( f"Using external prefixdir: {pdir}" )
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
            # ( package=package,packageversion=packageversion,
            #   installext=kwargs.get("installext",""),installvariant=kwargs.get("installvariant",""),
            #   mode=kwargs.get("mode"),
            # )
        prefixdir = f"{prefixdir}-{installext}"
    if not nonnull( prefixdir ):
        raise Exception( "failed to set prefixdir" )
    if nonnull( var := kwargs.get("installvariant","") ):
        prefixdir = f"{prefixdir}/{var}"
    return prefixdir
