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

def number_satisfies( l,w,**kwargs ):
    if False:
        return False
    elif re.match( r'<=',w ):
        w = w.lstrip('<=')
        return int(l)<=int(w)
    elif re.match( r'<',w ):
        w = w.lstrip('<')
        return int(l)<int(w)
    elif re.match( r'>=',w ):
        w = w.lstrip('>=')
        return int(l)>=int(w)
    elif re.match( r'>',w ):
        w = w.lstrip('>')
        return int(l)>int(w)
    elif l==w:
       return True
    else: return False

def version_satisfies( loaded,tomatch,**kwargs ):
    load_mjr,load_mnr,load_mcr = f"{loaded}.0.0".split(".",maxsplit=2)
    load_mnr = load_mnr.strip(".0")
    load_mcr = load_mcr.strip(".0")
    want_mjr,want_mnr,want_mcr = f"{tomatch}.99.99".split(".",maxsplit=2)
    for l,w in zip( [load_mjr,load_mnr,load_mcr],[want_mjr,want_mnr,want_mcr] ):
        if number_satisfies(l,w,**kwargs) or w=="99":
            echo_string( f"module version match load={l} want={w}",**kwargs )
            return True
        else:
            echo_string( f"module version mismatch load={l} want={w}",**kwargs )
            return False

