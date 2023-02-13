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
     && echo "Setting names for root=$1 package=$2 version=$3 ext=$4 basename=$5" >/dev/null \
	 && TACC_SYSTEM=${TACC_SYSTEM} systemcode \
	 && export scriptdir=`pwd` \
	 && PACKAGE=$2 && PACKAGEVERSION=$3 \
	 && export package=$( echo ${PACKAGE} | tr A-Z a-z ) \
	 && export PACKAGE=$( echo ${PACKAGE} | tr a-z A-Z ) \
	 && export packageversion=$( echo ${PACKAGEVERSION} | tr A-Z a-z ) \
	 && if [ -z "${packageversion}" ] ; then \
	        echo "No PACKAGEVERSION parameter given" && exit 1 ; fi \
	 && export homedir=$1/$package \
	 && if [ ! -z "$5" ] ; then \
	      export packagebasename=$5 \
	    ; else \
	      export packagebasename=$package \
	    ; fi \
	 && if [ ! -z "${SRCPATH}" ] ; then
	      export srcdir="${SRCPATH}" \
	    ; else \
	      export srcdir=$homedir/${packagebasename}-${packageversion} \
	    ; fi \
	 && if [ ! -z "${MODULEPATH}" ] ; then
	      export moduledir="${MODULEPATH}" \
	       && echo "Using explicit module path for package: $moduledir" \
	    ; else \
	      modulepath=${MODULEROOT} \
	       && if [ "${MODE}" = "mpi" ] ; then \
	            modulepath=${modulepath}/MPI/${LMOD_FAMILY_COMPILER}/${LMOD_FAMILY_COMPILER_VERSION}/${LMOD_FAMILY_MPI}/${LMOD_FAMILY_MPI_VERSION} \
	          ; else \
	            modulepath=${modulepath}/Compiler/${LMOD_FAMILY_COMPILER}/${LMOD_FAMILY_COMPILER_VERSION} \
	          ; fi \
	       && echo "Using constructed module path for package: $modulepath" \
	       && export moduledir=${modulepath}/${package} \
	    ; fi \
	 && echo "Module directory to store version: ${moduledir}" \
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
	 && echo "Using module version: ${moduleversion}" \
	 && export configurelog=configure-${installext}.log \
	 && export installlog=install-${installext}.log \
	 && export builddir=${homedir}/build-${installext} \
	 && if [ ! -z "${INSTALLPATH}" ] ; then \
	     export installdir=${INSTALLPATH} \
	   ; else \
	     if [ -z "${INSTALLROOT}" ] ; then \
	        export installdir=${homedir}/installation-${installext} \
	     ; else \
	        export installdir=${INSTALLROOT}/$package/installation-${installext} \
	   ; fi ; fi \
        && export varfile=${scriptdir}/vars-${installext}.sh
}

function reportnames () {
	echo "Installing package=${PACKAGE} version=${packageversion}" \
	 && echo "using directories:" \
	 && echo "srcdir=${srcdir}" \
	 && echo "builddir=${builddir}" \
	 && echo "installdir=${installdir}" \
	 && echo "logfiles: ${configurelog} ${installlog}"
}
