#------------------------------------------------------------------------#
# File Name: SinglePointRun.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# CESM1_2_2 user defined environment variables
PROGRAM_PATH=/wps/home/linxf/CLM/CLM4.5_install/software
MPICH=$PROGRAM_PATH/mpich-3.1.1
export INC_MPI=$MPICH/include
export LIB_MPI=$MPICH/lib
PATH=$MPICH/bin:$PATH
LD_LIBRARY_PATH=$MPICH/lib:$LD_LIBRARY_PATH
NETCDF=$PROGRAM_PATH/netcdf-4.3.3.1
export INC_NETCDF=$NETCDF/include
export LIB_NETCDF=$NETCDF/lib
export NETCDF_ROOT=$NETCDF
export USER_FC=gfortran
export USER_CC=gcc
export MYMACH=lxfpc

# single point running 
# part 1 single point surface data creating 
# preparing for the surface data creating
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export RUNDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_run
export DOUTDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_archive
export EXPOUT=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/exp_output
export MYDATA=/wps/home/linxf//CLM/cesm_indata
export GRIDNAME=1x1pt_CN-QYZ
#export CDATE=`date +%y%m%d`
export CDATE=170707
export GRIDFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapgrids/1x1pt_CN-QYZ_clm45/SCRIPgrid_${GRIDNAME}_nomask_c${CDATE}.nc
export MAPFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapdata/1x1pt_CN-QYZ_clm45/map_${GRIDNAME}_noocean_to_${GRIDNAME}_nomask_aave_da_${CDATE}.nc
export GENDOM_PATH=$MYDATA/share/domains/domain.clm
export OCNDOM=domain.ocn_noocean_clm45.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean_clm45.nc

# part 2 run with the surface data created
# |--step1--Copy the file (domain and surfdata files)you created above to your new directory naming convention (leave off the creation date)
# you need to edit the DATM namelist streams file to make it consistent
# $EDITOR Buildconf/datm.buildnml.csh
# |----copy the surfdata files into relevant directory
if [ ! -f "surfdata_${GRIDNAME}_simyr1850_clm45.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/surfdata_${GRIDNAME}_simyr1850_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr1850_clm45.nc
fi
if [ ! -f "surfdata_${GRIDNAME}_simyr2000_clm45.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/surfdata_${GRIDNAME}_simyr2000_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr2000_clm45.nc
fi
# |----copy the domain files into relevant directory
if [ ! -f "domain.lnd.${GRIDNAME}_noocean_clm45.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/1x1pt_CN-QYZ_clm45/domain.lnd.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.lnd.${GRIDNAME}_noocean.nc
fi
if [ ! -f "domain.ocn_noocean_clm45.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/1x1pt_CN-QYZ_clm45/domain.ocn.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.ocn_noocean_clm45.nc
fi
# |--step2--Put your forcing datasets into $MYDATA/atm/datm7/CLM1PT_data/$GRIDNAME
if [ ! -f "2005-01.nc" ]; then
	cp $MYDATA/atmforcing_make/${GRIDNAME}/2005-*.nc \
	$MYDATA/atm/datm7/CLM1PT_data/$GRIDNAME
fi
# |--step3--create,configure,build and run new case
cd $CCSMROOT/scripts
export CASE=${GRIDNAME}_${CDATE}_clm45
rm -rf ../clm45/SinglePointExp/$CASE
rm -rf $RUNDIR/$CASE
rm -rf $DOUTDIR/$CASE
./create_newcase -case ../clm45/SinglePointExp/$CASE -res CLM_USRDAT -compset ICLM45CN -mach lxfpc
cd ../clm45/SinglePointExp/$CASE
# add user specific namelist if do not create case using PTCLM
touch user_nl_clm
echo "fsurdat = '/wps/home/linxf/CLM/cesm_indata/lnd/clm2/surfdata/surfdata_1x1pt_CN-QYZ_simyr2000_clm45.nc'" > user_nl_clm
echo 'hist_nhtfrq = 1' >> user_nl_clm
echo 'hist_mfilt = 1200' >> user_nl_clm
# set CLM1PT and CLM_USRDAT_NAME
# to the user id you created for your datasets above
./xmlchange CLM_USRDAT_NAME=$GRIDNAME
# Set the path to the location of gen_domain set in the creation step above
./xmlchange ATM_DOMAIN_PATH=$GENDOM_PATH,LND_DOMAIN_PATH=$GENDOM_PATH
./xmlchange ATM_DOMAIN_FILE=$ATMDOM,LND_DOMAIN_FILE=$ATMDOM
./xmlchange DIN_LOC_ROOT=$MYDATA
# Set the DATM_MODE if compset is not I1PTCLM
./xmlchange DATM_MODE=CLM1PT
# Set the running year and output temporal resolution
./xmlchange STOP_OPTION=nsteps
./xmlchange STOP_N=17520
./xmlchange RUN_STARTDATE=2005-01-01
./xmlchange DATM_CLMNCEP_YR_ALIGN=2005
./xmlchange DATM_CLMNCEP_YR_START=2005
./xmlchange DATM_CLMNCEP_YR_END=2005
# configure the case
./cesm_setup > ${CASE}.setuplog
# modify the stream file 
# --create stream file
touch user_datm.streams.txt.CLM1PT.CLM_USRDAT
# --copy the content of steam file in $CASEROOT/CaseDocs to the new stream file
cat CaseDocs/datm.streams.txt.CLM1PT.CLM_USRDAT > user_datm.streams.txt.CLM1PT.CLM_USRDAT
# --edit the new stream file to make it consistent with DATM DATA &
# --eg.,delete nonexistent variables in atmforcing_make/${GRIDNAME}/2005-*.nc
sed -i '/ZBOT/d' user_datm.streams.txt.CLM1PT.CLM_USRDAT
sed -i '/PSRF/d' user_datm.streams.txt.CLM1PT.CLM_USRDAT
sed -i '/FLDS/d' user_datm.streams.txt.CLM1PT.CLM_USRDAT
./preview_namelists
# build the case
./${CASE}.build > ${CASE}.buildlog
# run the case
./${CASE}.run > ${CASE}.runlog
# copy the results into exp_output directory
 mkdir $EXPOUT/$CASE
 rm-rf $EXPOUT/$CASE
 cp $DOUTDIR/$CASE/lnd/hist/${CASE}.clm2.h0.*.nc $EXPOUT/$CASE
