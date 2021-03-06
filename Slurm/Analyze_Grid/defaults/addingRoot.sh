#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval $(scramv1 runtime -sh)

for dir in $(ls -d ${CMSSW_BASE}/src/Files/Analysis/WORK_DIRECTORY/*/)
do	    
    rootfiles=$(ls $dir | head -n1)
    if [ ! -z $rootfiles ]
    then
	allroot=$(find $dir*)
	echo $(basename $dir)
	hadd $(basename $dir).root $allroot

    fi
done

