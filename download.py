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
from process import echo_string
import names

def cd_download_path( **kwargs ):
    system   = kwargs.get("system",None)
    compiler = kwargs.get("compiler",None)
    root     = kwargs.get("root",None)
    package  = kwargs.get("package","nullpackage")
    version  = kwargs.get("version","0.0.0")
    downloadpath = kwargs.get("downloadpath","")
    if not re.match( r'[ \t\n]*$',downloadpath ):
        echo_string( f"Change dir to downloadpath: {downloadpath}",**kwargs )
        os.chdir( downloadpath )
    else:
        homedir = names.create_homedir\
            ( \
              system=system,compiler=compiler,
              root=root,package=package,version=version,
             )
        os.chdir(homedir)

def download_from_url( **kwargs, ):
    url = kwargs.get( "download" )
    downloadlog  = kwargs.pop( "logfile",open( f"{os.getcwd()}/download.log","w" ) )
    cd_download_path( **kwargs,logfile=downloadlog )
    if url == "":
        raise Exception("No URL given to download")
    echo_string( f"In download dir: {os.getcwd()} downloading {url}",logfile=downloadlog )
    tgz = re.sub( r'.*/','',url )
    process.process_execute( f"rm -f {tgz}" )
    cmdline=f"wget {url}"
    process.process_execute( cmdline,logfile=downloadlog,terminal=None )

def unpack_from_url( url,srcdir=None,**kwargs ):
    url = kwargs.get( "download" )
    downloadlog  = kwargs.pop( "logfile",open( f"{os.getcwd()}/unpack.log","w" ) )
    cd_download_path( **kwargs,logfile=downloadlog )
    echo_string( f"Unpacking in {os.getcwd()}",logfile=downloadlog )
    file = re.sub( r'.*/','',url )
    if re.match( file,r'^[ \t]*$' ):
        raise Exception( f"Unpack {url} gives empty file name" )
    if not os.path.isfile( f"./{file}" ):
        raise Exception( f"No such file {file} in directory {os.getcwd()}" )
    ext = re.sub( r'.*\.','',file )
    echo_string( f"Unpacking file: {file} ext: {ext}",logfile=downloadlog )
    if ext in [ "gz","tgz", ]:
        unpackdir = process.process_execute( f"tar ftz {file} | head -n 1" )
        unpackdir = re.sub( r'/$','',unpackdir )
        echo_string( f"Packed file contains directory: {unpackdir}")
        process.process_execute( f"rm -rf {unpackdir}" )
        process.process_execute( f"tar fxz {file}" )
    elif ext in [ "xz", "txz", ] :
        process.process_execute( f"xz --decompress {file}" )
        file = re.sub( r'\.xz','',file )
        if not re.match( r'^.*\.tar$',file ):
            raise Exception( f"Was expecting .tar suffix in {file}" )
        unpackdir = process.process_execute( f"tar ft {file} | head -n 1" )
        ## ( f"zcat {file} | head -n 1 | sed -e 's?/.*??' " )
        unpackdir = re.sub( r'/$','',unpackdir )
        echo_string( f"Packed file contains directory: {unpackdir}")
        process.process_execute( f"rm -rf {unpackdir}" )
        process.process_execute( f"tar fx {unpackdir}.tar" )
    else: raise Exception(f"Cannot unpack {file}")
    if srcdir:
        if unpackdir.lstrip("./") != srcdir:
            echo_string( f"Moving unpacked dir to srcdir: {srcdir}" )
            process.process_execute( f"mv {unpackdir} {srcdir}" )
        else:
            echo_string( f"Unpacked dir is at final name: {srcdir}" )
