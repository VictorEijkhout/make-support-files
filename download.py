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
    echo_string( f"In download dir: {os.getcwd()}" )
    cmdline=f"wget {url}"
    with open( "download.log", "w" ) as downloadlog:
        process.process_execute( cmdline,logfile=downloadlog )

def unpack_from_url( url,srcdir=None ):
    file = re.sub( r'.*/','',url )
    echo_string( f"Unpacking file: {file}" )
    ext = re.sub( r'.*\.','',file )
    if ext in [ "gz","tgz" ]:
        unpackdir = process.process_execute( f"tar ftz {file} | head -n 1" )
        echo_string( f"Packed file contains directory: {unpackdir}")
        process.process_execute( f"rm -rf {unpackdir}" )
        process.process_execute( f"tar fxz {file}" )
    else: raise f"Cannot unpack {file}"
    unpackdir = re.sub( r'/$','',unpackdir )
    if srcdir:
        echo_string( f"Moving unpacked dir to srcdir: {srcdir}" )
        process.process_execute( f"mv {unpackdir} {srcdir}" )

