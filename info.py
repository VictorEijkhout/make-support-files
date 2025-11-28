#!/usr/bin/env/python3

#
# standard python modules
#
import os
import re

#
# my own modules
#
import names
import process
from process import echo_string

def list_installations( **kwargs ):
    homedir = names.create_homedir( **kwargs ) # root=root,package=package, )
    dirs = [ d for d in os.listdir(homedir) if os.path.isdir(d) and re.match( 'installation',d ) ]
    echo_string( f"Found installations in homedir {homedir}\n{dirs}" )
    
