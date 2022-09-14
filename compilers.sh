function setcompilers () {
    echo "Setting compilers for ${TACC_FAMILY_COMPILER}" >/dev/null \
     && if [ "${TACC_FAMILY_COMPILER}" = "intel" ] ; then \
        export cc=icc && export cxx=icpc && export fc=ifort \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "intelx" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; elif [ "${TACC_FAMILY_COMPILER}" = "oneapi" ] ; then \
        export cc=icx && export cxx=icpx && export fc=ifx \
    ; else \
        export cc=gcc && export cxx=g++ && export fc=gfortran \
    ; fi
}

function setmpicompilers () {
    echo "Setting MPI compilers for ${TACC_FAMILY_COMPILER}" >/dev/null \
     && export cc=mpicc && export cxx=mpicxx && export fc=mpif90
}
