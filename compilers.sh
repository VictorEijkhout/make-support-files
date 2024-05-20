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
	       && export ompflag=-qopenmp \
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
		 && export ompflag=-fopenmp \
	; elif [ "${TACC_FAMILY_COMPILER}" = "gcc" ] ; then \
             export cc=gcc && export cxx=g++ && export fc=gfortran \
		 && export ompflag=-fopenmp \
	; else \
             export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
		 && export ompflag=-fopenmp \
        ; fi \
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
     && export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
     && export CC=$cc && export CXX=$cxx && export FC=$fc \
     && reportcompilers
}

function reportcompilers () {
    echo "Using compilers:" \
     && echo " .. CC=${CC}" \
     && echo "    where ${CC}=$( which ${CC} )" \
     && echo " .. CXX=${CXX}" \
     && echo "    where ${CXX}=$( which ${CXX} )" \
     && echo " .. FC=${FC}" \
     && echo "    where ${FC}=$( which ${FC} )" \
     && if [ "${MODE}" = "mpi" ] ; then \
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
        ; fi
}
