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
	@export MODE=${MODE} \
	 && source ${MAKEINCLUDES}/names.sh \
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
	            VERSION=${VERSION} GITDATE=${GITDATE} \
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
	     && echo "Modules loaded: $$( module -t list 2>&1 | tr '\n' ' ' )" 2>/dev/null \
	     && source ${MAKEINCLUDES}/compilers.sh \
	     && if [ "${MODE}" = "mpi" -o "${MODE}" = "hybrid" ] ; then \
	          setmpicompilers ; else setcompilers ; fi \
	     && reportcompilers \
	     \
	     && rm -rf $$builddir && mkdir -p $$builddir \
	     && find $$builddir -name CMakeCache.txt -exec rm {} \; \
	     \
	     && if [ ! -z "${CPPSTANDARD}" ] ; then \
	            cppstandard="-D CMAKE_CXX_FLAGS=-std=c++${CPPSTANDARD}" ; fi \
	     && if [ $$( uname ) = Darwin ] ; then \
	          CMAKEFLAGSPLATFORM="-D CMAKE_LINKER_FLAGS=-ld_classic" ; fi \
	     \
	     && if [ ! -z "${CMAKEPREP}" ] ; then \
	          echo "Prep command: ${CMAKEPREP}" \
	           && ( cd $${srcdir} \
	                 && echo "${CMAKEPREP}" > VLE_prep.sh \
	                 && source VLE_prep.sh \
	              ) \
	        ; fi \
	     \
	     && if [ ! -z "${CMAKECOMPILERFLAGS}" ] ; then \
	            echo "Exporting compiler flags to <<${CMAKECOMPILERFLAGS}>>" \
	             && export CXXFLAGS="$${CXXFLAGS} ${CMAKECOMPILERFLAGS}" \
	             && export CFLAGS="$${CFLAGS} ${CMAKECOMPILERFLAGS}" \
	             && export FFLAGS="$${FFLAGS} ${CMAKECOMPILERFLAGS}" \
	        ; fi \
	     \
	     && if [ -z "${CMAKENAME}" ] ; then \
	          cmake=cmake \
	           && echo "Using cmake=$$( which cmake )" \
	        ; else cmake=${CMAKENAME} \
	           && echo "Using cmake=$$(cmake)" \
	        ; fi \
	     && if [ ! -z "${CMAKEBUILDTYPE}" ] ; then \
	          cmakebuildtype=${CMAKEBUILDTYPE} \
	        ; elif [ ! -z "${CMAKEBUILDDEBUG}" ] ; then \
	          cmakebuildtype=Debug ; else cmakebuildtype=RelWithDebInfo \
	        ; fi \
	     && cmdline="$${cmake} -D CMAKE_INSTALL_PREFIX=$$prefixdir \
	            $$( if [ ! -z "${COLORDIAGNOSTICSOFF}" ] ; then echo -DCMAKE_COLOR_DIAGNOSTICS=OFF ; fi ) \
	            $$( if [ -z '' ] ; then echo -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF ; fi ) \
	            -D CMAKE_VERBOSE_MAKEFILE=ON \
	            -D BUILD_SHARED_LIBS=$$( if [ -z "${BUILDSTATICLIBS}" ] ; then echo ON; else echo OFF ; fi ) \
	            -D CMAKE_BUILD_TYPE=$${cmakebuildtype} \
	            ${CMAKEFLAGS} $${CMAKEFLAGSPLATFORM} $$cppstandard" \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            cmdline="$${cmdline} -S $${srcdir}/${CMAKESOURCE} -B $$builddir" \
	        ; else \
	            cmdline="$${cmdline} $${srcdir}/${CMAKESUBDIR}" \
	        ; fi \
	     && echo "cmdline=$$cmdline" \
	     && ( cd $$builddir && eval $$cmdline ) \
	    ) 2>&1 | tee $$configurelog
	@echo && echo "CMake configuration ended: $$( date )" && echo 

