# -*- makefile -*-
info ::
	@echo "================ cmake configure:"
	@echo "make configure"
	@echo "    [ CMAKEFLAGS=... ] [ INSTALLEXT=... (extra extension ) ] "
	@echo "    [ PKG_CONFIG_PATHS / PKG_CONFIG_ADDS = .... ]"
	@echo "    [ CMAKE_PREFIX_PATH / CMAKE_PREFIX_ADDS = ... ]"
.PHONY: configure cmakeopts
cmakeopts ::
	@touch cmakeopts
configure : cmakeopts
	@( \
	    source ${MAKEINCLUDES}/names.sh \
	     && export MODE=${MODE} \
	     && setnames ${PACKAGEROOT} ${PACKAGE} ${PACKAGEVERSION} ${INSTALLEXT} \
	     && export varfile=$${scriptdir}/vars-$$installext.sh \
	     && set -x \
	     && rm -rf $$builddir && mkdir -p $$builddir \
	     && find $$builddir -name CMakeCache.txt -exec rm {} \; \
	     && export PKG_CONFIG_PATH=${PKG_CONFIG_ADDS}${PKG_CONFIG_PATH} \
	     && export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_ADDS}${CMAKE_PREFIX_PATH} \
	     && if [ ! -z "${CMAKEPREP}" ] ; then eval ${CMAKEPREP} ; fi \
	     && if [ "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
	            export CC=icc && export CXX="icpc -std=c++17" \
	        ; elif [ "${TACC_FAMILY_COMPILER}" = "intelx" ] ; then \
	            export CC=icx && export CXX=icpx \
	        ; elif [ "${TACC_FAMILY_COMPILER}" = "clang" ] ; then \
	            export CC=clang && export CXX=clang++ \
	        ; else \
	            export CC=gcc && export CXX="g++ -std=c++17" \
	        ; fi \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                -S $$srcdir/${CMAKESOURCE} -B $$builddir \
	        ; else \
	            ( cd $$builddir \
	             && cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                    $$srcdir \
	            ) \
	        ; fi \
	     && ( \
	            echo "# Installation variables for ${PACKAGE}" \
	             && echo "# Using CC=$$CC CXX=$$CXX FC=$$FC" \
	             && echo "export TACC_${PACKAGE}_DIR=$${installdir}" \
	             && echo "export TACC_${PACKAGE}_LIB=$${installdir}/lib" \
	             && echo "export TACC_${PACKAGE}_INC=$${installdir}/include" \
	         ) \
	        ${VARSPROCESS} \
	        >$$varfile \
	     && echo "Variable settings in $$varfile" \
	    ) 2>&1 | tee configure.log

