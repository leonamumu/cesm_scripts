#------------------------------------------------------------------------#
# File Name: SinglePointRun.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/sh
# single point running 
# step1 set environment variables
PROGRAM_PATH=/wps/home/linxf/programFiles
MPICH=$PROGRAM_PATH/mpich2
export INC_MPI=$MPICH/include
export LIB_MPI=$MPICH/lib
PATH=$MPICH/bin:$PATH
LD_LIBRARY_PATH=$MPICH/lib:$LD_LIBRARY_PATH
NETCDF=$PROGRAM_PATH/netcdf4.1.2
export INC_NETCDF=$NETCDF/include
export LIB_NETCDF=$NETCDF/lib
export NETCDF_ROOT=$NETCDF
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_0_3
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export RUNDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_run
export DOUTDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive
export EXPOUT=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/exp_output
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export USER_FC=ifort   
export USER_CC=icc   
export MYMACH=lxfpc   
export SITE=CN-QYZ
export GRIDNAME=1x1pt_CN-QYZ
export CDATE=`date +%y%m%d`
export MYCASE=${CDATE}_CN-QYZ_ICN

# step2 creat dataset
cd $CCSMROOT/models/lnd/clm/tools/mkgriddata
gmake
gmake clean
cd ../mksurfdata
gmake
gmake clean
cd ../mkdatadomain
gmake
gmake clean

# step3 use PTCLM to create spinup case
# note: you should add site information into PTCLM_sitedata before running PTCLM.py
cd $CCSMROOT/scripts/ccsm_utils/Tools/lnd/clm/PTCLM
export CASEROOT=$CCSMROOT/singlePointExp
rm -rf $CASEROOT/$MYCASE
rm -rf $RUNDIR/$MYCASE
rm -rf $DOUTDIR/$MYCASE
./PTCLM.py -m $MYMACH --case=$CASEROOT/${CDATE} --site=$SITE --csmdata=$MYDATA --compset=ICN --aerdepgrid --ndepgrid --run_n 17520 --run_units nsteps

# step4 configure,build and run new case
chmod -R 755 $CASEROOT/$MYCASE/
cd $CASEROOT/$MYCASE

# modify the temperal resolution of output data
sed -i '3c \ hist_mfilt=17520' user_nl_clm

# modify the env_conf.xml and env_run.xml
./xmlchange -file env_conf.xml -id RUN_STARTDATE -val "2005-01-01"
./xmlchange -file env_conf.xml -id DATM_MODE -val "CLM1PT"
./xmlchange -file env_conf.xml -id DATM_CLMNCEP_YR_ALIGN -val "2005"
./xmlchange -file env_conf.xml -id DATM_CLMNCEP_YR_START -val "2005"
./xmlchange -file env_conf.xml -id DATM_CLMNCEP_YR_END -val "2005"
./xmlchange -file env_conf.xml -id CLM_NAMELIST_OPTS -val "hist_nhtfrq=1"
./xmlchange -file env_conf.xml -id CLM_USRDAT_NAME -val $GRIDNAME
./xmlchange -file env_conf.xml -id CLM_PT1_NAME -val $GRIDNAME
./xmlchange -file env_run.xml -id STOP_OPTION -val "nsteps"
./xmlchange -file env_run.xml -id STOP_N -val "17520"

# modify the streams file or copy the correct file before configure the case
# --eg.,delete nonexistent variables in atmforcing_make/${GRIDNAME}/2005-*.nc
sed -i '/ZBOT/d' ./Tools/Templates/datm.template.streams.xml
sed -i '/PSRF/d' ./Tools/Templates/datm.template.streams.xml
sed -i '/FLDS/d' ./Tools/Templates/datm.template.streams.xml
# or [rm ./Tools/Templates/datm.template.streams.xml
# cp $CCSMROOT/lxf_case_files/datm.template.streams.xml ./Tools/Templates/]

# configure the case
./configure '-case' > ${MYCASE}.setuplog
# build the case
./${MYCASE}.${MYMACH}.build > ${MYCASE}.buildlog
# run the case
bsub -e ${MYCASE}.err -o ${MYCASE}.out ./${MYCASE}.${MYMACH}.run
# copy the results into exp_output directory
 rm -rf $EXPOUT/$CASE
 mkdir $EXPOUT/$CASE
 cp $DOUTDIR/$CASE/lnd/hist/${CASE}.clm2.h0.*.nc $EXPOUT/$CASE
