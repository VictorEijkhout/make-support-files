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

def test_modules( **kwargs ):
    modules = kwargs.get( "modules","" )
    for m in modules.split(" "):
        mod,ver = m.split('/')
        echo_string( f"test presence of module={mod} version={ver}" )
        
