# -*- makefile -*-
function setnames () {
    echo "Setting names for root=$1 package=$2 version=$3 ext=$4 basename=%5" >/dev/null \
	&& export scriptdir=`pwd` \
	&& PACKAGE=$2 \
	&& package=$( echo ${PACKAGE} | tr A-Z a-z ) \
	&& export homedir=$1/$package \
	&& if [ ! -z "$5" ] ; then \
	        export packagebasename=$5 \
	    ; else \
	        export packagebasename=$package \
	    ; fi \
	&& export srcdir=$homedir/${packagebasename}-$3 \
	&& export installext=$3-${TACC_SYSTEM}-${TACC_FAMILY_COMPILER}-${TACC_FAMILY_MPI} \
	&& if [ ! -z "$4" -a ! "$4" = "keep" ] ; then \
	       export installext=${installext}-$4 ; fi \
	&& export builddir=$homedir/build-${installext} \
        && export installdir=$homedir/installation-${installext}
}
