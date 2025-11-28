#!/usr/bin/env python3

##
## python modules
##
import re
import subprocess
import sys

def echo_string( string,logfile=None,terminal=sys.stdout ):
    if  terminal:
        print( string,file=terminal )
    if logfile is not None:
        print( string,file=logfile )

def nonnull( val ):
    return not re.match( r'^[ \t\n]*$',val )

def requirenonzero( var ):
    try:
        val = locals()[var]
        if val == "":
            raise Exception( f"variable is zero: {var}" )
    except:
        pass

def unimplemented( var ):
    try:
        val = locals()[var]
    except:
        pass

def process_execute( cmdline,**kwargs ):
    process = kwargs.get("process",None)
    logfile = kwargs.get("logfile",None)
    terminal = kwargs.get( "terminal",sys.stdout )
    if logfile is None:
        logfile = sys.stdout
    if process is None:
        process = subprocess.Popen\
            (['/bin/bash', '-l'], 
             stdin=subprocess.PIPE, 
             stdout=subprocess.PIPE, 
             stderr=subprocess.STDOUT,
             text=True,
             bufsize=1)
    echo_string( f"Command line={cmdline}" )
    process_input = process.stdin
    process_input.write( cmdline+"\n" )
    process_input.flush()
    process_input.close()
    echo_string( "Output:" )
    lastline = ""
    while True:
        line = process.stdout.readline()
        if not line:
            break
        line = re.sub( r'^[ \t]*','', re.sub( r'[ \t\n]*$','', line ) )
        if line != "":
            echo_string( line,terminal=terminal )
            lastline = line
    echo_string( " .. end of output" )
    process.wait()
    return lastline
