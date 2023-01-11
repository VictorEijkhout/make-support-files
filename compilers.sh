function setcompilers () {
    if [ -z "${LMOD_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable LMOD_FAMILY_COMPILER not set" ; \
	fi 
    echo "Setting compilers for ${LMOD_FAMILY_COMPILER}" >/dev/null \
     && if [ "${LMOD_FAMILY_COMPILER}" = "intel" ] ; then \
        export cc=icc && export cxx=icpc && export fc=ifort \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "intelx" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "clang" ] ; then \
        export cc=clang && export cxx=clang++ && export fc=gfortran \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "gcc" ] ; then \
        export cc=gcc && export cxx=g++ && export fc=gfortran \
    ; elif [ "${LMOD_FAMILY_COMPILER}" = "oneapi" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; else \
        export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
    ; fi \
    && export CC=$cc && export CXX=$cxx && export FC=$fc
}

function setmpicompilers () {
    echo "Setting MPI compilers for ${LMOD_FAMILY_COMPILER}" >/dev/null \
     && export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
     && export CC=$cc && export CXX=$cxx && export FC=$fc
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
