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
	&& package=$( echo ${PACKAGE} | tr A-Z a-z ) \
	&& PACKAGE=$( echo ${PACKAGE} | tr a-z A-Z ) \
	&& export homedir=$1/$package \
	&& if [ ! -z "$5" ] ; then \
	        export packagebasename=$5 \
	    ; else \
	        export packagebasename=$package \
	    ; fi \
	&& export srcdir=$homedir/${packagebasename}-$3 \
	&& if [ "${MODE}" = "seq" ] ; then \
	        export installext=$3-${TACC_SYSTEM}-${TACC_FAMILY_COMPILER} \
	        ; \
	   else \
	        export installext=$3-${TACC_SYSTEM}-${TACC_FAMILY_COMPILER}-${TACC_FAMILY_MPI} \
	        ; \
	   fi \
	&& if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export installext=${installext}-$4 ; fi \
	&& export builddir=$homedir/build-${installext} \
        && if [ -z "${INSTALLROOT}" ] ; then \
	    export installdir=$homedir/installation-${installext} \
	   ; else \
	    export installdir=${INSTALLROOT}/$package/installation-${installext} \
	   ; fi \
        && export varfile=$${scriptdir}/vars-$$installext.sh \
}
