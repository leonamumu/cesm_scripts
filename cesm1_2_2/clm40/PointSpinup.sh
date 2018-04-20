#------------------------------------------------------------------------#
# File Name: SinglePointRun.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# single point running 
# part 1 single point surface data creating 
# preparing for the surface data creating
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export Macros=/wps/home/linxf/CLM/cesm_code/cesm1_2_2/build_files
export RUNDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_run
export DOUTDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_archive
export EXPOUT=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/exp_output
export GRIDNAME=1x1pt_CN-QYZ
export CDATE=170708
export GRIDFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapgrids/SCRIPgrid_${GRIDNAME}_nomask_c${CDATE}.nc
export MAPFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapdata/1x1pt_CN-QYZ_clm40/map_${GRIDNAME}_noocean_to_${GRIDNAME}_nomask_aave_da_${CDATE}.nc
export GENDOM_PATH=$MYDATA/share/domains/domain.clm
export OCNDOM=domain.ocn_noocean_clm40.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean_clm40.nc
# part 2 run with the surface data created
# |--step1--Copy the file (domain and surfdata files)you created above to your new directory naming convention (leave off the creation date)
# you need to edit the DATM namelist streams file to make it consistent
# $EDITOR Buildconf/datm.buildnml.csh
# |----copy the surfdata files into relevant directory
if [ ! -f "surfdata_${GRIDNAME}_simyr1850_clm40.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_0/mksurfdata_map/surfdata_${GRIDNAME}_simyr1850_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr1850_clm40.nc
fi
if [ ! -f "surfdata_${GRIDNAME}_simyr2000_clm40.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_0/mksurfdata_map/surfdata_${GRIDNAME}_simyr2000_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr2000_clm40.nc
fi
# |----copy the domain files into relevant directory
if [ ! -f "domain.lnd.${GRIDNAME}_noocean_clm40.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/1x1pt_CN-QYZ_clm40/domain.lnd.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.lnd.${GRIDNAME}_noocean_clm40.nc
fi
if [ ! -f "domain.ocn_noocean_clm40.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/1x1pt_CN-QYZ_clm40/domain.ocn.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.ocn_noocean_clm40.nc
fi
# |--step2--create,configure,build and run new case
cd $CCSMROOT/scripts
export CASE=${GRIDNAME}_spinup_clm40
rm -rf ../clm40/spinupExp/$CASE
rm -rf $RUNDIR/$CASE
rm -rf $DOUTDIR/$CASE
./create_newcase -case ../clm40/spinupExp/$CASE -res CLM_USRDAT -compset ICN -mach lxfpc
cd ../clm40/spinupExp/$CASE
# add user specific namelist if do not create case using PTCLM
touch user_nl_clm
echo "fsurdat = '/wps/home/linxf/CLM/cesm_indata/lnd/clm2/surfdata/surfdata_1x1pt_CN-QYZ_simyr2000_clm40.nc'" > user_nl_clm
echo 'hist_nhtfrq = -8760' >> user_nl_clm
# set CLM1PT and CLM_USRDAT_NAME
# to the user id you created for your datasets above
./xmlchange CLM_USRDAT_NAME=$GRIDNAME
# Set the path to the location of gen_domain set in the creation step above
./xmlchange ATM_DOMAIN_PATH=$GENDOM_PATH,LND_DOMAIN_PATH=$GENDOM_PATH
./xmlchange ATM_DOMAIN_FILE=$ATMDOM,LND_DOMAIN_FILE=$ATMDOM
./xmlchange DIN_LOC_ROOT=$MYDATA
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup
# Set the running year and output temporal resolution
./xmlchange RESUBMIT=30,STOP_N=20,STOP_OPTION=nyears,STOP_DATE=6010101
# configure the case
./cesm_setup > ${CASE}.setuplog
# build the case
cp $Macros/Macros ./
./${CASE}.build > ${CASE}.buildlog
# run the case
bsub -e point_spinup.err -o point_spinup.out -n 10 ./${CASE}.run
# copy the results into exp_output directory
# mkdir $EXPOUT/$CASE
# cp $DOUTDIR/$CASE/lnd/hist/${CASE}.clm2.h0.*.nc $EXPOUT/$CASE
