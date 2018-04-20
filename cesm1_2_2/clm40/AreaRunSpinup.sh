#------------------------------------------------------------------------#
# File Name: AreaRun.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 29 Jun 2017 20:30:28 PM CST
#------------------------------------------------------------------------#

#!/bin/bash
# area running 
# preparing for the area running
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export RUNDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_run
export DOUTDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/clm_archive
export EXPOUT=/wps/home/linxf/CLM/cesm_outdata/cesm1_2_2/exp_output
export MYDATA=/wps/home/linxf//CLM/cesm_indata
export GRIDNAME=0.5x0.5_BeiJing
export CDATE=`date +%y%m%d`
#export CDATE=170629
export CASE=BGC_BJ_0.5x0.5
export GRIDFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapgrids/SCRIPgrid_${GRIDNAME}_nomask_c${CDATE}.nc
export MAPFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapdata/map_${GRIDNAME}_noocean_to_${GRIDNAME}_nomask_aave_da_${CDATE}.nc
export GENDOM_PATH=$MYDATA/share/domains/domain.clm
export OCNDOM=domain.ocn_noocean.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean.nc

# |--step1--Copy the file (domain and surfdata files)you created above to your new directory naming convention (leave off the creation date)
# |----copy the surfdata files into relevant directory
if [ ! -f "surfdata_${GRIDNAME}_simyr1850.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/surfdata_${GRIDNAME}_simyr1850_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr1850.nc
fi
if [ ! -f "surfdata_${GRIDNAME}_simyr2000.nc" ]; then
	cp $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/surfdata_${GRIDNAME}_simyr2000_c$CDATE.nc \
	$MYDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr2000.nc
fi
# |----copy the domain files into relevant directory
if [ ! -f "domain.lnd.${GRIDNAME}_noocean.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/domain.lnd.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.lnd.${GRIDNAME}_noocean.nc
fi
if [ ! -f "domain.ocn_noocean.nc" ]; then
	cp $CCSMROOT/tools/mapping/gen_domain_files/domain.ocn.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.${CDATE}.nc \
	$MYDATA/share/domains/domain.clm/domain.ocn_noocean.nc
fi

# |--step2--create,configure,build and run new case
cd $CCSMROOT/scripts
rm -rf ../AreaExp/$CASE
rm -rf $RUNDIR/$CASE
rm -rf $DOUTDIR/$CASE
./create_newcase -case ../AreaExp/$CASE -res CLM_USRDAT -compset ICRUCLM45BGC -mach lxfpc
cd ../AreaExp/$CASE

# add user specific namelist
touch user_nl_clm
echo "fsurdat = '/wps/home/linxf/CLM/cesm_indata/lnd/clm2/surfdata/surfdata_1x1pt_CN-QYZ_simyr2000.nc'" > user_nl_clm
# set CLM1PT and CLM_USRDAT_NAME
# to the user id you created for your datasets above
./xmlchange CLM_USRDAT_NAME=$GRIDNAME
# Set the path to the location of gen_domain set in the creation step above
./xmlchange ATM_DOMAIN_PATH=$GENDOM_PATH,LND_DOMAIN_PATH=$GENDOM_PATH
./xmlchange ATM_DOMAIN_FILE=$ATMDOM,LND_DOMAIN_FILE=$ATMDOM
./xmlchange DIN_LOC_ROOT=$MYDATA
# modify the path when use CRU forcing
./xmlchange DIN_LOC_ROOT_CLMFORC=$CSMDATA/atm/datm7
# modify the pio type and other parameters
./xmlchange PIO_TYPENAME=pnetcdf
./xmlchange MPILIB=mpich,COMPILER=gnu
./xmlchange NTASKS_CPL=10,NTASKS_ROF=10,NTASKS_ICE=10,NTASKS_WAV=10,NTASKS_OCN=10,NTASKS_GLC=10,MAX_TASKS_PER_NODE=10,NTASKS_LND=10,NTASKS_ATM=10
# configure the case
./cesm_setup > ${CASE}.setuplog
# build the case
./${CASE}.build > ${CASE}.buildlog
# run the case
./xmlchange RESUBMIT=20,STOP_N=50,STOP_OPTION=nyears,STOP_DATE=10010101
bsub -e CLM45BGC_spinup.err -o_CLM45BGC_spinup.out -n 10 ./${CASE}.run > ${CASE}.runlog
# copy the results into exp_output directory
mkdir $EXPOUT/$CASE
cp $DOUTDIR/$CASE/lnd/hist/${CASE}.clm2.h0.*.nc $EXPOUT/$CASE
