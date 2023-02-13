# -*- makefile -*-
.PHONY: cmake_info
cmake_info :
	@echo "================ cmake configure:"
	@echo "make configure"
info :: cmake_info
moreinfo :: cmake_info
	@echo "    [ CMAKEFLAGS=... ] [ INSTALLEXT=... (extra extension ) ] "
	@echo "    [ PKGCONFIGSET :  non-blank is added to vars file ]"
	@echo "    [ PKG_CONFIG_PATHS / PKG_CONFIG_ADDS = .... ]"
	@echo "    [ CMAKE_PREFIX_PATH / CMAKE_PREFIX_ADDS = ... ]"
	@echo "    [ INSTALLROOT=... (alternative install root) ]"

.PHONY: configure cmakeopts
cmakeopts ::
	@touch .cmakeopts
configure : modules cmakeopts
	@source ${MAKEINCLUDES}/names.sh \
	 && export MODE=${MODE} && export INSTALLROOT=${INSTALLROOT} \
	 && setnames ${PACKAGEROOT} ${PACKAGE} ${PACKAGEVERSION} ${INSTALLEXT} \
	 && source ${MAKEINCLUDES}/compilers.sh \
	 && if [ "${MODE}" = "mpi" ] ; then \
	      setmpicompilers ; else setcompilers ; fi \
	 && ( \
	    rm -rf $$builddir && mkdir -p $$builddir \
	     && find $$builddir -name CMakeCache.txt -exec rm {} \; \
	     \
	     && export PKGCONFIGPATH=${PKG_CONFIG_PATH} \
	     && export PKGCONFIGPATH=${PKG_CONFIG_ADDS}$${PKGCONFIGPATH} \
	     && export PKG_CONFIG_PATH=$${PKGCONFIGPATH} \
	     \
	     && export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_ADDS}${CMAKE_PREFIX_PATH} \
	     && if [ ! -z "${CMAKEPREP}" ] ; then eval ${CMAKEPREP} ; fi \
	     && echo "Cmaking with src=$$srcdir build=$$builddir" \
	     && reportcompilers \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                -D CMAKE_VERBOSE_MAKEFILE=ON \
	                -S $$srcdir/${CMAKESOURCE} -B $$builddir \
	        ; else \
	            ( cd $$builddir \
	             && cmdline="cmake -D CMAKE_INSTALL_PREFIX=$$installdir ${CMAKEFLAGS} \
	                    -D CMAKE_VERBOSE_MAKEFILE=ON \
	                    $$srcdir" \
	             && if [ "${ECHO}" = "1" ] ; then \
	                    echo "cmdline=$$cmdline" ; fi \
	             && eval $$cmdline \
	            ) \
	        ; fi \
	    ) 2>&1 | tee $$configurelog
novarsfile :
	foo \
	     && make --no-print-directory varsfile VARSFILE=$$varfile \
	            PACKAGE=${PACKAGE} \
	            INSTALLDIR="$${installdir}" \
	            LIBDIR="$${installdir}/lib" \
	            INCDIR="$${installdir}/include" \
	            PKGCONFIGSET="${PKGCONFIGSET}" \
	foo
