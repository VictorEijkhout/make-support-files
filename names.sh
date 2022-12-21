# -*- makefile -*-
function setnames () {
    if [ -z "${TACC_SYSTEM}" ] ; then \
	echo "WARNING: variable TACC_SYSTEM not set" ; \
	fi 
    if [ -z "${TACC_FAMILY_COMPILER}" ] ; then \
	echo "WARNING: variable TACC_FAMILY_COMPILER not set" ; \
	fi 
    echo "Setting names for root=$1 package=$2 version=$3 ext=$4 basename=%5" >/dev/null \
	&& export scriptdir=`pwd` \
	&& PACKAGE=$2 \
	&& export package=$( echo ${PACKAGE} | tr A-Z a-z ) \
	&& export PACKAGE=$( echo ${PACKAGE} | tr a-z A-Z ) \
	&& export packageversion=$3 \
	&& export homedir=$1/$package \
	&& if [ ! -z "$5" ] ; then \
	      export packagebasename=$5 \
	    ; else \
	      export packagebasename=$package \
	    ; fi \
	&& export srcdir=$homedir/${packagebasename}-${packageversion} \
	&& export moduledir=${MODULEROOT}/${TACC_FAMILY_COMPILER} \
	&& export moduleversion=${packageversion} \
	&& if [ "${MODE}" = "seq" ] ; then \
	      export installext=${packageversion}-${TACC_SYSTEM}-${TACC_FAMILY_COMPILER} \
	        ; \
	   else \
	      export installext=${packageversion}-${TACC_SYSTEM}-${TACC_FAMILY_COMPILER}-${TACC_FAMILY_MPI} \
	       && export moduledir=${moduledir}/${TACC_FAMILY_MPI} \
	        ; \
	   fi \
	&& export moduledir=${moduledir}/${package} \
	&& if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export installext=${installext}-$4 \
	        && export moduleversion=${moduleversion}-$4 \
	   ; fi \
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
