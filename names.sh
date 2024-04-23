# -*- makefile -*-
function notetoself() {
	echo $1 >/dev/null
}

function systemnames () {
	if [ "${TACC_SYSTEM}" = "stampede2" ] ; then \
	  export taccsystemcode=skx \
	; elif [ "${TACC_SYSTEM}" = "frontera" ] ; then \
	  export taccsystemcode=clx \
	; elif [ "${TACC_SYSTEM}" = "ls6" ] ; then \
	  export taccsystemcode=milan \
	; elif [ ! -z "${TACC_SYSTEM_CODE}" ] ; then \
	  export taccsystemcode=${TACC_SYSTEM_CODE} \
	; else \
	  export taccsystemcode=${TACC_SYSTEM} \
	; fi
}

function compilernames () {
	if [ ! -z "${TACC_FAMILY_COMPILER}" ] ; then \
	    export compilercode="${TACC_FAMILY_COMPILER}" \
	     && export compilerversion="${TACC_FAMILY_COMPILER_VERSION}" \
	; fi 
	export compilershortversion=${compilerversion%%.*}
	if [ ! -z "${TACC_FAMILY_MPI}" ] ; then \
	    export mpicode="${TACC_FAMILY_MPI}" \
	     && export mpiversion="${TACC_FAMILY_MPI_VERSION}" \
	; fi 
}

# $1 = package, $2 = packageversion, $3 = packagebasename 
function packagenames () {
    if [ -z "$2" -o ! -z "$4" ] ; then \
	echo "function packagenames needs 2 parameters, 3rd optional" ; fi \
     && PACKAGE=$1 \
     && if [ -z "${PACKAGE}" ] ; then \
          echo "packagenames called with null package" && exit 1 ; fi \
     && export package=$( echo ${PACKAGE} | tr A-Z a-z ) \
     && export PACKAGE=$( echo ${PACKAGE} | tr a-z A-Z ) \
     && PACKAGEVERSION=$2 \
     && export packageversion=$( echo ${PACKAGEVERSION} | tr A-Z a-z ) \
     && requirenonzero packageversion \
     && if [ ! -z "$3" ] ; then \
          export packagebasename=$3 \
        ; else \
          export packagebasename=$package \
        ; fi
}

function lognames () {
    installext=$1 \
     && export configurelog=configure-${installext}.log \
     && export installlog=install-${installext}.log
}

# This probably assumes that you have done 
#     packagenames "${PACKAGE}" "${PACKAGEVERSION}" "${PACKAGEBASENAME}" 
# then this only needs MODULENAME parameter
function modulenames () {
	TACC_SYSTEM=${TACC_SYSTEM} systemnames && compilernames \
	 && requirenonzero packageversion \
	 && requirenonzero compilercode \
	 && requirenonzero compilerversion \
	 && if [ ! -z "$1" ] ; then \
	      export modulename=$1 ; else export modulename=${package} ; fi \
	 && requirenonzero modulename \
	 && if [ ! -z "${MODULEDIRSET}" ] ; then \
	        export moduledir=${MODULEDIRSET} \
	    ; else \
	        if [ -z "${MODULEROOT}" ] ; then
	          echo "Please set MODULEROOT variable" && exit 1 ; fi \
	         && modulepath=${MODULEROOT} \
	         && if [ "${mode}" = "mpi" ] ; then \
	                requirenonzero mpicode \
	                 && modulepath=${modulepath}/MPI/${compilercode}/${compilerversion}/${mpicode}/${mpiversion} \
	            ; elif [ "${mode}" = "seq" ] ; then \
	                modulepath=${modulepath}/Compiler/${compilercode}/${compilerversion} \
	            ; elif [ ! -z "${mode}" ] ; then \
	                echo "ERROR: unknown mode: ${mode}" && exit 1 \
	            ; fi \
	         && if [ ! -z "${modulename}" ] ; then \
	                export moduledir=${modulepath}/${modulename} \
	            ; else \
	                export moduledir=${modulepath}/${package} \
	            ; fi \
	    ; fi \
	 && export moduleversion=${packageversion} \
	 && if [ ! -z "${variant}" ] ; then \
	      export moduleversion=${moduleversion}-${variant} ; fi \
	 && if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export moduleversion=${moduleversion}-$4 \
	   ; fi \
}

function setnames () {
    PACKAGE=${1} && PACKAGEVERSION=${2} && PACKAGEBASENAME=${3} \
     && DOWNLOADPATH=${4} && SRCPATH=${5} \
     && INSTALLPATH=${6} && INSTALLROOT=${7} && INSTALLEXT=${8} && INSTALLVARIANT=${9} \
     && HOMEDIR=${10} && BUILDDIRROOT=${11} && MODE=${12} \
     && PREFIXOPTION=${13} && PREFIXEXTRA=${14} \
     && installext=$( make --no-print-directory installext \
        PACKAGEVERSION=${PACKAGEVERSION} MODE=${MODE} \
        INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
        ) \
     && requirenonzero installext \
     && lognames $installext \
     && requirenonzero configurelog \
     && requirenonzero installlog \
     && export srcdir=$( make --no-print-directory srcdir \
            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
            PACKAGEBASENAME=${PACKAGEBASENAME} \
            DOWNLOADPATH=${DOWNLOADPATH} SRCPATH=${SRCPATH} \
            ) \
     && reportnonzero srcdir \
     && export builddir=$( make --no-print-directory builddir \
            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
            PACKAGEBASENAME=${PACKAGEBASENAME} MODE=${MODE} \
            HOMEDIR=${HOMEDIR} BUILDDIRROOT=${BUILDDIRROOT} \
            INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
            ) \
     && reportnonzero builddir \
     && export prefixdir=$( make --no-print-directory prefixdir \
            PACKAGE=${PACKAGE} PACKAGEVERSION=${PACKAGEVERSION} \
            PACKAGEBASENAME=${PACKAGEBASENAME} MODE=${MODE} \
            INSTALLPATH=${INSTALLPATH} INSTALLROOT=${INSTALLROOT} \
            INSTALLEXT=${INSTALLEXT} INSTALLVARIANT=${INSTALLVARIANT} \
            ) \
     && reportnonzero prefixdir \
     && if [ ! -z "${PREFIXEXTRA}" ] ; then \
            echo "prefix: attaching PREFIXEXTRA=${PREFIXEXTRA}" \
             && export prefixdir=${prefixdir}-${PREFIXEXTRA} ; fi
}

function requirenonzero () {
	eval r=\${$1} \
	 && if [ -z "$r" ] ; then \
	      echo "Internal Error: zero variable <<$1>>" && exit 1 \
	    ; fi \
	 && if [ $( echo $1 | grep ":" | wc -l ) -gt 0 ] ; then \
	      echo "Please no colons in paths / directory names" && exit 1 \
	    ; fi 
}

function reportnonzero () {
	eval r=\${$1} \
	 && if [ -z "$r" ] ; then \
	      echo "Internal Error: zero variable <<$1>>" && exit 1 \
	    ; fi \
	 && if [ $( echo $1 | grep ":" | wc -l ) -gt 0 ] ; then \
	      echo "Please no colons in paths / directory names" && exit 1 \
	    ; fi \
	 && if [ ! -z "$2" ] ; then \
	      echo "$2 $1: $r" ; else echo "$1: $r" ; fi
}

function requirenonzeropath () {
	requirenonzero "$1" \
	 && eval r=\${$1} \
	 && if [ ! -d "$r" ] ; then \
	      echo "Non-existing path: $1=$r" && exit 1 ; fi
}

function reportnames () {
	echo "Installing package=${PACKAGE} version=${packageversion} at $(date)" \
	 && echo " .. using compiler:" \
	 && echo "    compiler=${compilercode}/${compilerversion} (short: ${comilershortversion})" \
	 && echo "    mpi=${mpicode}/${mpiversion}" \
	 && echo " .. using names:" \
	 && echo "    srcdir=${srcdir}" \
	 && echo "    builddir=${builddir}" \
	 && echo "    prefixdir=${prefixdir}" \
	 && echo "    logfiles: ${configurelog} ${installlog}"
}

##
## old stuff
##
