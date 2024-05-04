# -*- makefile -*-
.PHONY: cmake_info
cmake_info :
	@echo "================ cmake configure:"
	@echo "make configure"
info :: cmake_info
moreinfo :: cmake_info
	@echo "    [ CMAKEFLAGS=... ] [ INSTALLEXT=... (extra extension ) ] "
	@echo "    [ PKGCONFIG :  non-blank is added to vars file ]"
	@echo "    [ PKG_CONFIG_PATHS / PKG_CONFIG_ADDS = .... ]"
	@echo "    [ CMAKE_PREFIX_PATH / CMAKE_PREFIX_ADDS = ... ]"
	@echo "    [ INSTALLROOT=... (alternative install root) ]"

.PHONY: configure 
configure : modules
	@source ${MAKEINCLUDES}/names.sh \
	 && installext=$$( make --no-print-directory installext \
	        PACKAGEVERSION=${PACKAGEVERSION} MODE=${MODE} \
	        INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
	        ) \
	 && requirenonzero installext \
	 && lognames $$installext \
	 && requirenonzero configurelog \
	 && ( \
	    echo "CMake configure stage" \
	     && export srcdir=$$( make --no-print-directory srcdir \
	            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
	            PACKAGEBASENAME=${PACKAGEBASENAME} \
	            DOWNLOADPATH=${DOWNLOADPATH} SRCPATH=${SRCPATH} \
	            ) \
	     && reportnonzero srcdir \
	     && export builddir=$$( make --no-print-directory builddir \
	            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
	            PACKAGEBASENAME=${PACKAGEBASENAME} MODE=${MODE} \
	            HOMEDIR=${HOMEDIR} BUILDDIRROOT=${BUILDDIRROOT} \
	            INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
	            ) \
	     && reportnonzero builddir \
	     && export prefixdir=$$( make --no-print-directory prefixdir \
	            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
	            PACKAGEBASENAME=${PACKAGEBASENAME} MODE=${MODE} \
	            INSTALLPATH=${INSTALLPATH} INSTALLROOT=${INSTALLROOT} \
	            INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
	            ) \
	     && reportnonzero prefixdir \
	     \
	     && source ${MAKEINCLUDES}/compilers.sh \
	     && if [ "${MODE}" = "mpi" ] ; then \
	          setmpicompilers ; else setcompilers ; fi \
	     && reportcompilers \
	     \
	     && rm -rf $$builddir && mkdir -p $$builddir \
	     && find $$builddir -name CMakeCache.txt -exec rm {} \; \
	     \
	     && export PKGCONFIGPATH=${PKG_CONFIG_PATH} \
	     && export PKGCONFIGPATH=${PKG_CONFIG_ADDS}$${PKGCONFIGPATH} \
	     && export PKG_CONFIG_PATH=$${PKGCONFIGPATH} \
	     && if [ ! -z "$${PKG_CONFIG_PATH}" ] ; then \
	          echo "Using PKG_CONFIG_PATH = $${PKG_CONFIG_PATH}" ; fi \
	     \
	     && export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_ADDS}${CMAKE_PREFIX_PATH} \
	     && if [ ! -z "$${CMAKE_PREFIX_PATH}" ] ; then \
	          echo "Using CMAKE_PREFIX_PATH = $${CMAKE_PREFIX_PATH}" ; fi \
	     \
	     && export CMAKE_MODULE_PATH=${CMAKE_MODULE_ADDS}${CMAKE_MODULE_PATH} \
	     && if [ ! -z "$${CMAKE_MODULE_PATH}" ] ; then \
	          echo "Using CMAKE_MODULE_PATH = $${CMAKE_MODULE_PATH}" ; fi \
	     \
	     && if [ ! -z "${CPPSTANDARD}" ] ; then \
	            cppstandard="-D CMAKE_CXX_FLAGS=-std=c++${CPPSTANDARD}" ; fi \
	     && if [ $$( uname ) = Darwin ] ; then \
	          CMAKEFLAGSPLATFORM="-D CMAKE_LINKER_FLAGS=-ld_classic" ; fi \
	     \
	     && if [ ! -z "${CMAKEPREP}" ] ; then eval ${CMAKEPREP} ; fi \
	     \
	     && if [ ! -z "${CMAKECOMPILERFLAGS}" ] ; then \
	            echo "Exporting compiler flags to <<${CMAKECOMPILERFLAGS}>>" \
	             && export CXXFLAGS="${CMAKECOMPILERFLAGS}" \
	             && export CFLAGS="${CMAKECOMPILERFLAGS}" \
	             && export FFLAGS="${CMAKECOMPILERFLAGS}" \
	        ; fi \
	     \
	     && if [ -z "${CMAKENAME}" ] ; then \
	          cmake=cmake ; else cmake=${CMAKENAME} ; fi \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            $${cmake} -D CMAKE_INSTALL_PREFIX=$$prefixdir \
	                -D CMAKE_COLOR_DIAGNOSTICS=OFF \
	                -D CMAKE_VERBOSE_MAKEFILE=ON \
	                -D BUILD_SHARED_LIBS=ON \
	                ${CMAKEFLAGS} $${CMAKEFLAGSPLATFORM} $$cppstandard \
	                -S $$srcdir/${CMAKESOURCE} -B $$builddir \
	        ; else \
	            ( cd $$builddir \
	             && cmdline="$${cmake} -D CMAKE_INSTALL_PREFIX=$$prefixdir \
	                    -D CMAKE_COLOR_DIAGNOSTICS=OFF \
	                    -D CMAKE_VERBOSE_MAKEFILE=ON \
	                    -D BUILD_SHARED_LIBS=ON \
	                    ${CMAKEFLAGS} $${CMAKEFLAGSPLATFORM} $$cppstandard \
	                    $${srcdir}/${CMAKESUBDIR}" \
	             && echo "cmdline=$$cmdline" \
	             && eval $$cmdline \
	            ) \
	        ; fi \
	    ) 2>&1 | tee $$configurelog
	@echo && echo "CMake configuration ended: $$( date )" && echo 

