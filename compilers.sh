# -*- bash -*-
function setcompilers () {
    if [ -z "${TACC_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable LMOD/TACC_FAMILY_COMPILER not set" ; \
	fi 
    echo "Setting compilers for ${TACC_FAMILY_COMPILER}" \
     && compiler_version=${TACC_FAMILY_COMPILER_VERSION} \
     && compiler_version=${compiler_version%%.*} \
     && echo " .. version ${compiler_version}" \
     && if [ ! -z "${TACC_CC}" ] ; then \
	 export cc=${TACC_CC} \
	  && export cxx=${TACC_CXX} \
	  && export fc=${TACC_FC} \
	; elif [ "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
	   if [ ${compiler_version} -lt 23 ] ; then \
	       export cc=icc && export cxx=icpc && export fc=ifort \
	       ; else \
	       export cc=icx && export cxx=icpx && export fc=ifx \
	       ; fi \
	; elif [ "${TACC_FAMILY_COMPILER}" = "clang" ] ; then \
	     if [ "${TACC_SYSTEM}" = "macbookair" ] ; then \
		 export cc=clang-mp-16 \
		     && export cxx=clang++-mp-16 \
		     && export fc=gfortran \
		 ; else \
		 export cc=clang \
		     && export cxx=clang++ \
		     && export fc=gfortran \
		 ; fi \
	; elif [ "${TACC_FAMILY_COMPILER}" = "gcc" ] ; then \
             export cc=gcc && export cxx=g++ && export fc=gfortran \
	; else \
             export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
        ; fi \
    && if [ "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
	 export ompflag=-qopenmp \
       ; else export ompflag=-fopenmp ; fi \
    && if [ ! -z "${EXPLICITCOMPILERS}" ] ; then \
         export cc=$( which ${cc} ) \
	  && export cxx=$( which ${cxx} ) \
	  && export fc=$( which ${fc} ) \
	  && echo "long compiler paths" \
       ; fi \
    && export CC=$cc && export CXX=$cxx && export FC=$fc
}

function setmpicompilers () {
    echo "Setting MPI compilers for ${TACC_FAMILY_COMPILER}" >/dev/null \
     && setcompilers \
     && if [ ! -z "${TACC_MPICC}" ]; then \
          export cc="${TACC_MPICC}" \
	; else \
	  export cc=mpicc \
	; fi \
     && if [ ! -z "${TACC_MPIFC}" ]; then \
          export fc="${TACC_MPIFC}" \
	; else \
	  export fc=mpif90 \
	; fi \
     && export cxx=mpicxx \
     && export CC=${cc} && export CXX=${cxx} && export FC=${fc} \
     && if [ "${MODE}" = "hybrid" ] ; then
	  export CFLAGS="${ompflag}" && export CXXFLAGS="${ompflag}" \
	   && export FFLAGS="${ompflag}" \
	; fi
}

function reportcompilers () {
    echo "Using compilers for mode ${MODE}:" \
     && echo " .. TACC_CC=${TACC_CC}" \
     && echo " .. CC=${CC}" \
     && echo "    where ${CC}=$( which ${CC} )" \
     && echo "    and CFLAGS=${CFLAGS}" \
     && echo " .. TACC_CXX=${TACC_CXX}" \
     && echo " .. CXX=${CXX}" \
     && echo "    where ${CXX}=$( which ${CXX} )" \
     && echo "    and CXXFLAGS=${CXXFLAGS}" \
     && echo " .. TACC_FC=${TACC_FC}" \
     && echo " .. FC=${FC}" \
     && if [ ! -z "${FC}" ] ; then \
	 echo "    where ${FC}=$( which ${FC} )" \
	 ; fi \
     && echo "    and FFLAGS=${FFLAGS}" \
     && if [ "${MODE}" = "mpi" -o "${MODE}" = "hybrid" ] ; then \
	    echo "  where:" \
	     && testcompiler=$( mpicc -show ) \
	     && echo "    mpicc=$( which mpicc )" \
	     && echo "    show: ${testcompiler}" \
	     && basecompiler=$( echo ${testcompiler} | cut -f 1 -d " " ) \
	     && echo "    where ${basecompiler}=$( which ${basecompiler} )" \
	    \
	     && testcompiler=$( mpicxx -show ) \
	     && echo "    mpicxx=$( which mpicxx )" \
	     && echo "    show:  ${testcompiler}" \
	     && basecompiler=$( echo ${testcompiler} | cut -f 1 -d " " ) \
	     && echo "    where ${basecompiler}=$( which ${basecompiler} )" \
	    \
	     && testcompiler=$( mpif90 -show ) \
	     && echo "    mpif90=$( which mpif90 )" \
	     && echo "    show:  ${testcompiler}" \
	     && basecompiler=$( echo ${testcompiler} | cut -f 1 -d " " ) \
	     && echo "    where ${basecompiler}=$( which ${basecompiler} )" \
        ; fi \
	     \
	&& echo "Using LD_LIBRARY_PATH = $( echo ${LD_LIBRARY_PATH} | tr ':' '\n' )" \
	&& export PKGCONFIGPATH=${PKG_CONFIG_PATH} \
	&& export PKGCONFIGPATH=${PKG_CONFIG_ADDS}${PKGCONFIGPATH} \
	&& export PKG_CONFIG_PATH=${PKGCONFIGPATH} \
	&& if [ ! -z "${PKG_CONFIG_PATH}" ] ; then \
	      echo "Using PKG_CONFIG_PATH = $( echo ${PKG_CONFIG_PATH} | tr ':' '\n' )" \
	   ; fi \
	\
	&& export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_ADDS}${CMAKE_PREFIX_PATH} \
	&& if [ ! -z "${CMAKE_PREFIX_PATH}" ] ; then \
	      echo "Using CMAKE_PREFIX_PATH = $( echo ${CMAKE_PREFIX_PATH} | tr ':' '\n' )" \
	   ; fi \
	\
	&& export CMAKE_MODULE_PATH=${CMAKE_MODULE_ADDS}${CMAKE_MODULE_PATH} \
	&& if [ ! -z "${CMAKE_MODULE_PATH}" ] ; then \
	      echo "Using CMAKE_MODULE_PATH = $( echo ${CMAKE_MODULE_PATH} | tr ':' '\n' )" \
	   ; fi
}
