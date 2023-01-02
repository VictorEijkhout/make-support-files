function setcompilers () {
    if [ -z "${TACC_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable TACC_FAMILY_COMPILER not set" ; \
	fi 
    echo "Setting compilers for ${TACC_FAMILY_COMPILER}" >/dev/null \
     && if [ "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
        export cc=icc && export cxx=icpc && export fc=ifort \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "intelx" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "clang" ] ; then \
        export cc=clang && export cxx=clang++ && export fc=gfortran \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "gcc" ] ; then \
        export cc=gcc && export cxx=g++ && export fc=gfortran \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "oneapi" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; else \
        export cc=mpicc && export cxx=mpicxx && export fc=mpif90 \
    ; fi
}

function setmpicompilers () {
    echo "Setting MPI compilers for ${TACC_FAMILY_COMPILER}" >/dev/null \
     && export cc=mpicc && export cxx=mpicxx && export fc=mpif90
}

function reportcompilers () {
    echo "Using compilers:" \
     && echo "  CC=${CC}, CXX=${CXX}, FC=${FC}" \
     && if [ "${MODE}" = "mpi" ] ; then \
	    echo "  where:" \
	     && echo "  mpicc=$( mpicc -show )" \
        ; fi
}
