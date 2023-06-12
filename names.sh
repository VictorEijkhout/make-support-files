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
	if [ ! -z "${LMOD_FAMILY_COMPILER}" ] ; then \
	    export compilercode="${LMOD_FAMILY_COMPILER}" \
	     && export compilerversion="${LMOD_FAMILY_COMPILER_VERSION}" \
	; else \
	    export compilercode="${TACC_FAMILY_COMPILER}" \
	     && export compilerversion="${TACC_FAMILY_COMPILER_VERSION}" \
	; fi 
	export compilershortversion=${compilerversion%%.*}
	if [ ! -z "${LMOD_FAMILY_MPI}" ] ; then \
	    export mpicode="${LMOD_FAMILY_MPI}" \
	     && export mpiversion="${LMOD_FAMILY_MPI_VERSION}" \
	; else \
	    export mpicode="${TACC_FAMILY_MPI}" \
	     && export mpiversion="${TACC_FAMILY_MPI_VERSION}" \
	; fi 
}

function setnames () {
    if [ -z "${TACC_SYSTEM}" ] ; then \
	echo "WARNING: variable TACC_SYSTEM not set" ; \
	fi \
    && if [ -z "${LMOD_FAMILY_COMPILER}" -a -z "${TACC_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable LMOD/TACC_FAMILY_COMPILER not set" ; \
	fi \
    && if [ -z "$1" ] ; then \
	echo "ERROR: variable PACKAGEROOT not set" && exit 1 ; fi \
     && echo "Setting names for root=$1 package=$2 version=$3 ext=$4 basename=$5 variant=$6" \
	 && TACC_SYSTEM=${TACC_SYSTEM} systemnames \
	 && PACKAGE=$2 && PACKAGEVERSION=$3 \
	 && export package=$( echo ${PACKAGE} | tr A-Z a-z ) \
	 && export PACKAGE=$( echo ${PACKAGE} | tr a-z A-Z ) \
	 && export packageversion=$( echo ${PACKAGEVERSION} | tr A-Z a-z ) \
	 && if [ -z "${HOMEDIR}" ] ; then \
	      export homedir=$1/$package \
	    ; else \
	      export homedir="${HOMEDIR}" \
	    ; fi \
	 && if [ -z "${packageversion}" ] ; then \
	        echo "No PACKAGEVERSION parameter given" && exit 1 ; fi \
	 && if [ ! -z "$5" ] ; then \
	      export packagebasename=$5 \
	    ; else \
	      export packagebasename=$package \
	    ; fi \
	 && export variant="$6" \
	 && if [ ! -z "${DOWNLOADPATH}" ] ; then \
	        export downloaddir="${DOWNLOADPATH}" \
	    ; else \
	        export downloaddir=$homedir \
	    ; fi \
	 && if [ ! -z "${SRCPATH}" ] ; then
	      export srcdir="${SRCPATH}" \
	    ; else \
	      export srcdir=${downloaddir}/${packagebasename}-${packageversion} \
	    ; fi
}

function setmodulenames () {
	TACC_SYSTEM=${TACC_SYSTEM} systemnames && compilernames \
	 && requirenonzero packageversion \
	 && requirenonzero compilercode \
	 && requirenonzero compilerversion \
	 && if [ ! -z "${MODULEDIRSET}" ] ; then \
	        export moduledir=${MODULEDIRSET} \
	    ; else \
	        if [ -z "${MODULEROOT}" ] ; then
	          echo "Please set MODULEROOT variable" && exit 1 ; fi \
	         && modulepath=${MODULEROOT} \
	         && if [ "${MODE}" = "mpi" ] ; then \
	                modulepath=${modulepath}/MPI/${compilercode}/${compilerversion}/${mpicode}/${mpiversion} \
	            ; else \
	                modulepath=${modulepath}/Compiler/${compilercode}/${compilerversion} \
	            ; fi \
	         && if [ ! -z "${MODULENAME}" ] ; then \
	                export moduledir=${modulepath}/${MODULENAME} \
	            ; else \
	                export moduledir=${modulepath}/${package} \
	            ; fi \
	    ; fi \
	 && export moduleversion=${packageversion} \
	 && if [ ! -z "${variant}" ] ; then \
	      export moduleversion=${moduleversion}-${variant} ; fi \
	 && if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export installext=${installext}-$4 \
	        && export moduleversion=${moduleversion}-$4 \
	   ; fi \
}

function setdirlognames() {
	export scriptdir=`pwd` \
	 && systemnames && compilernames \
	 && setnames       "$1" "$2" "$3" "$4" "$5" "$6" \
	 && setmodulenames "$1" "$2" "$3" "$4" "$5" "$6" \
	 && requirenonzero taccsystemcode \
	 && requirenonzero compilercode \
	 &&  export \
               installext=${packageversion}-${taccsystemcode}-${compilercode}${compilershortversion} \
	 && if [ "${MODE}" = "mpi" ] ; then \
	      requirenonzero mpicode \
	       && export installext=${installext}-${mpicode} \
	   ; fi \
	 && if [ ! -z "${variant}" ] ; then \
	      export installext=${installext}-${variant} ; fi \
	 && export configurelog=configure-${installext}.log \
	 && export installlog=install-${installext}.log \
	 && export builddir=${homedir}/build-${installext} \
	 && if [ -z "$package" ] ; then \
	      echo "No package name for dirlog" && exit 1 ; fi \
	 && if [ ! -z "${INSTALLPATH}" ] ; then \
	     export installdir=${INSTALLPATH} \
	   ; else \
	     if [ -z "${INSTALLROOT}" ] ; then \
	        export installdir=${homedir}/installation-${installext} \
	     ; else \
	        export installdir=${INSTALLROOT}/$package/installation-${installext} \
	   ; fi ; fi
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

function reportnames () {
	echo "Installing package=${PACKAGE} version=${packageversion} at $(date)" \
	 && echo "using directories:" \
	 && echo "srcdir=${srcdir}" \
	 && echo "builddir=${builddir}" \
	 && echo "installdir=${installdir}" \
	 && echo "logfiles: ${configurelog} ${installlog}"
}
