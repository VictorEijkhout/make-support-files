# -*- makefile -*-
info ::
	@echo "================ cmake configure:"
	@echo "make configure"
	@echo "    [ CMAKEFLAGS=... ] [ INSTALLEXT=... (extra extension ) ] "
	@echo "    [ PKGCONFIGSET :  non-blank is added to vars file ]"
	@echo "    [ PKG_CONFIG_PATHS / PKG_CONFIG_ADDS = .... ]"
	@echo "    [ CMAKE_PREFIX_PATH / CMAKE_PREFIX_ADDS = ... ]"
	@echo "    [ INSTALLROOT=... (alternative install root) ]"
.PHONY: configure cmakeopts
cmakeopts ::
	@touch cmakeopts
configure : cmakeopts
	@( \
	    source ${MAKEINCLUDES}/names.sh \
	     && export MODE=${MODE} && export INSTALLROOT=${INSTALLROOT} \
	     && setnames ${PACKAGEROOT} ${PACKAGE} ${PACKAGEVERSION} ${INSTALLEXT} \
	     && export varfile=$${scriptdir}/vars-$$installext.sh \
	     && rm -rf $$builddir && mkdir -p $$builddir \
	     && find $$builddir -name CMakeCache.txt -exec rm {} \; \
	     \
	     && export PKGCONFIGPATH=${PKG_CONFIG_PATH} \
	     && export PKGCONFIGPATH=${PKG_CONFIG_ADDS}$${PKGCONFIGPATH} \
	     && export PKG_CONFIG_PATH=$${PKGCONFIGPATH} \
	     \
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
	     && echo "Cmake src=$$srcdir build=$$builddir" \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                -S $$srcdir/${CMAKESOURCE} -B $$builddir \
	        ; else \
	            ( cd $$builddir \
	             && cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                    $$srcdir \
	            ) \
	        ; fi \
	     && make --no-print-directory varsfile VARFILE=$$varfile \
	            PACKAGE=${PACKAGE} \
	            INSTALLDIR="$${installdir}" \
	            LIBDIR="$${installdir}/lib" \
	            INCDIR="$${installdir}/include" \
	            PKGCONFIGSET="${PKGCONFIGSET}" \
	    ) 2>&1 | tee configure.log
include ${MAKEINCLUDES}/Make.vars
