#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

CMS_BASE=$(pwd)

##########################################
######## CREATING CONFIG FILES ###########
##########################################
if [ ! -z $(echo ${CMSSW_BASE} | grep CMSSW_8_0) ]
then
    cmsDriver.py Hadronizer_TuneCUETP8M1_13TeV_generic_LHE_pythia8_cff.py \
	--filein file:${CMS_BASE}/events.lhe --fileout OUTFILE -n 271828 \
	--conditions 80X_mcRun2_asymptotic_2016_miniAODv2 --fast \
	--eventcontent AODSIM -s GEN,SIM,RECOBEFMIX,DIGI,L1,L1Reco,RECO \
	--datatier AODSIM \ #--pileup 2016_25ns_SpringMC_PUScenarioV1_PoissonOOTPU \
    --beamspot NominalCollision2015 \
	--era Run2_25ns \
	--magField 38T_PostLS1 \
	--python_filename fastsim_default_cfg.py \
	--no_exec

    cmsDriver.py step3  \
	--filein file:INFILE --fileout OUTFILE -n 271828 \
	--conditions 80X_mcRun2_asymptotic_2016_miniAODv2 --fast -s PAT \
	--eventcontent MINIAODSIM \
	--runUnscheduled  \
	--datatier MINIAODSIM \
	--era Run2_25ns --mc \
	--no_exec \
	--python_filename pat_default_cfg.py

elif [ ! -z $(echo ${CMSSW_BASE} | grep CMSSW_7_4) ]
then
    cmsDriver.py Hadronizer_TuneCUETP8M1_13TeV_generic_LHE_pythia8_cff.py \
	--filein file:${CMS_BASE}/events.lhe --fileout OUTFILE -n 271828 \
	--conditions MCRUN2_74_V9 --fast \
	--eventcontent AODSIM -s GEN,SIM,RECOBEFMIX,DIGI,L1,L1Reco,RECO,HLT:@frozen25ns \
	--datatier AODSIM \
	--beamspot NominalCollision2015 \
	--customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 \
	--magField 38T_PostLS1 \
	--python_filename fastsim_default_cfg.py \
	--no_exec

### work on getting pileup to work with slurm: xroot not working is why
#    --pileup=2015_25ns_Startup_PoissonOOTPU \

    cmsDriver.py step3  \
	--filein file:INFILE --fileout OUTFILE -n 271828 \
	--conditions MCRUN2_74_V9 --fast -s PAT \
	--eventcontent MINIAODSIM \
	--runUnscheduled  \
	--datatier MINIAODSIM \
	--customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --mc \
	--no_exec \
	--python_filename pat_default_cfg.py
fi

sed -i -e s/271828/NUMBER_EVENT/g fastsim_default_cfg.py
sed -i -e s/271828/NUMBER_EVENT/g pat_default_cfg.py
sed -i -e 's/"LHESource",/"LHESource",skipEvents = cms\.untracked\.uint32(SKIPPER),/g' fastsim_default_cfg.py


############################################
############# FIXING RUN FILES #############
############################################

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_fastsim.sh

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_pat.sh
