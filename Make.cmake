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
	 && export INSTALLROOT=${INSTALLROOT} \
	 && setdirlognames "${PACKAGEROOT}" "${PACKAGE}" "${PACKAGEVERSION}" "${INSTALLEXT}" "${PACKAGEBASENAME}" "${VARIANT}" "${MODULENAME}" "${MODE}" \
	 && source ${MAKEINCLUDES}/compilers.sh \
	 && if [ "$${mode}" = "mpi" ] ; then \
	      setmpicompilers ; else setcompilers ; fi \
	 && ( \
	    echo "Start of CMake configure" \
	     && reportnames \
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
	     && echo "Cmaking with src=$$srcdir build=$$builddir" \
	     && cmake --version | head -n 1 \
	     && reportcompilers && echo \
	     && if [ -z "${CMAKENAME}" ] ; then \
	          cmake=cmake ; else cmake=${CMAKENAME} ; fi \
	     && if [ ! -z "${CMAKESOURCE}" ] ; then \
	            $${cmake} -D CMAKE_INSTALL_PREFIX=$$installdir \
	                -D CMAKE_COLOR_DIAGNOSTICS=OFF \
	                -D CMAKE_VERBOSE_MAKEFILE=ON \
	                -D BUILD_SHARED_LIBS=ON \
	                ${CMAKEFLAGS} \
	                -S $$srcdir/${CMAKESOURCE} -B $$builddir \
	        ; else \
	            ( cd $$builddir \
	             && cmdline="$${cmake} -D CMAKE_INSTALL_PREFIX=$$installdir \
	                    -D CMAKE_COLOR_DIAGNOSTICS=OFF \
	                    -D CMAKE_VERBOSE_MAKEFILE=ON \
	                    -D BUILD_SHARED_LIBS=ON \
	                    ${CMAKEFLAGS} $$cppstandard \
	                    $${srcdir}/${CMAKESUBDIR}" \
	             && echo "cmdline=$$cmdline" \
	             && eval $$cmdline \
	            ) \
	        ; fi \
	    ) 2>&1 | tee $$configurelog
	@echo && echo "CMake configuration ended: $$( date )" && echo 

