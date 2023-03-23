# -*- makefile -*-
function systemcode () {
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

function setnames () {
    if [ -z "${TACC_SYSTEM}" ] ; then \
	echo "WARNING: variable TACC_SYSTEM not set" ; \
	fi \
    && if [ -z "${LMOD_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable LMOD_FAMILY_COMPILER not set" ; \
	fi \
    && if [ -z "$1" ] ; then \
	echo "ERROR: variable PACKAGEROOT not set" && exit 1 ; fi \
     && echo "Setting names for root=$1 package=$2 version=$3 ext=$4 basename=$5" >/dev/null \
	 && TACC_SYSTEM=${TACC_SYSTEM} systemcode \
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

function setdirlognames() {
	export scriptdir=`pwd` \
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

function setmodulenames () {
	TACC_SYSTEM=${TACC_SYSTEM} systemcode \
	 && if [ -z "$packageversion" ] ; then \
	      echo "No packageversion for module names" && exit 1 ; fi \
	 && if [ ! -z "${MODULEDIRSET}" ] ; then \
	        export moduledir=${MODULEDIRSET} \
	    ; else \
	        if [ -z "${MODULEROOT}" ] ; then
	          echo "Please set MODULEROOT variable" && exit 1 ; fi \
	         && modulepath=${MODULEROOT} \
	         && if [ "${MODE}" = "mpi" ] ; then \
	                modulepath=${modulepath}/MPI/${LMOD_FAMILY_COMPILER}/${LMOD_FAMILY_COMPILER_VERSION}/${LMOD_FAMILY_MPI}/${LMOD_FAMILY_MPI_VERSION} \
	            ; else \
	                modulepath=${modulepath}/Compiler/${LMOD_FAMILY_COMPILER}/${LMOD_FAMILY_COMPILER_VERSION} \
	            ; fi \
	         && export moduledir=${modulepath}/${package} \
	    ; fi \
	 && export moduleversion=${packageversion} \
	 && if [ "${MODE}" = "seq" ] ; then \
	      export installext=${packageversion}-${taccsystemcode}-${LMOD_FAMILY_COMPILER} \
	   ; else \
	      export installext=${packageversion}-${taccsystemcode}-${LMOD_FAMILY_COMPILER}-${LMOD_FAMILY_MPI} \
	   ; fi \
	 && if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export installext=${installext}-$4 \
	        && export moduleversion=${moduleversion}-$4 \
	   ; fi \
}

function reportnames () {
	echo "Installing package=${PACKAGE} version=${packageversion}" \
	 && echo "using directories:" \
	 && echo "srcdir=${srcdir}" \
	 && echo "builddir=${builddir}" \
	 && echo "installdir=${installdir}" \
	 && echo "logfiles: ${configurelog} ${installlog}"
}
