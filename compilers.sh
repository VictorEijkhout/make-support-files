function setcompilers () {
    if [ -z "${LMOD_FAMILY_COMPILER}" -a -z "${TACC_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable LMOD/TACC_FAMILY_COMPILER not set" ; \
	fi 
    echo "Setting compilers for ${LMOD_FAMILY_COMPILER}" >/dev/null \
     && compiler_version=${TACC_FAMILY_COMPILER_VERSION} \
     && compiler_version=${compiler_version%%.*} \
     && if [ "${LMOD_FAMILY_COMPILER}" = "intel" -o "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
	if [ ${compiler_version} -lt 23 ] ; then \
	    export cc=icc && export cxx=icpc && export fc=ifort \
	; else \
	    export cc=icx && export cxx=icpx && export fc=ifx \
	; fi \
     && export ompflag=-qopenmp \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "clang" ] ; then \
        export cc=clang && export cxx=clang++ && export fc=gfortran \
	export ompflag=-fopenmp \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "gcc" -o "${TACC_FAMILY_COMPILER}" = "gcc" ] ; then \
        export cc=gcc && export cxx=g++ && export fc=gfortran \
	export ompflag=-fopenmp \
    ; else \
        export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
	export ompflag=-fopenmp \
    ; fi \
    && export CC=$cc && export CXX=$cxx && export FC=$fc
}

function setmpicompilers () {
    echo "Setting MPI compilers for ${LMOD_FAMILY_COMPILER}" >/dev/null \
     && setcompilers \
     && export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
     && export CC=$cc && export CXX=$cxx && export FC=$fc \

}

function reportcompilers () {
    echo "Using compilers:" \
     && echo "  CC=${CC}, CXX=${CXX}, FC=${FC}" \
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
