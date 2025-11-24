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

def download_from_url( url ):
    " assume with are in the right download directory "
    if url == "":
        raise Exception("No URL given to download")
    echo_string( f"In download dir: {os.getcwd()} downloading {url}" )
    tgz = re.sub( r'.*/','',url )
    process.process_execute( f"rm -f {tgz}" )
    cmdline=f"wget {url}"
    with open( "download.log", "w" ) as downloadlog:
        process.process_execute( cmdline,logfile=downloadlog )

def unpack_from_url( url,srcdir=None ):
    echo_string( f"Unpacking in {os.getcwd()}" )
    file = re.sub( r'.*/','',url )
    if re.match( file,r'^[ \t]*$' ):
        raise Exception( f"Unpack {url} gives empty file name" )
    if not os.path.isfile( f"./{file}" ):
        raise Exception( f"No such file {file} in directory {os.getcwd()}" )
    ext = re.sub( r'.*\.','',file )
    echo_string( f"Unpacking file: {file} ext: {ext}" )
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
        echo_string( f"Moving unpacked dir to srcdir: {srcdir}" )
        process.process_execute( f"mv {unpackdir} {srcdir}" )

