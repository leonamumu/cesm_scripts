#------------------------------------------------------------------------#
# File Name: SinglePointSpinup.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# single point running 

# step1 set environment variables
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_0_3
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export RUNDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_run
export DOUTDIR=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive
export EXPOUT=/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/exp_output
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export INC_NETCDF=/wps/home/linxf/programFiles/netcdf4.1.2/include   
export LIB_NETCDF=/wps/home/linxf/programFiles/netcdf4.1.2/lib   
export USER_FC=ifort   
export USER_CC=icc   
export MYMACH=lxfpc   
export SITE=CN-QYZ
export MYCASE=lxf_CN-QYZ_ICN_QIAN_ad_spinup

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
export CASEROOT=$CCSMROOT/spinupExp
rm -rf $CCSMROOT/spinupExp/$MYCASE
rm -rf $RUNDIR/$MYCASE
rm -rf $DOUTDIR/$MYCASE
./PTCLM.py -m $MYMACH --case=$CASEROOT/lxf -s $SITE -d $CSMDATA --ad_spinup --useQIAN --QIAN_tower_yrs --aerdepgrid --ndepgrid

# step4 configure,build and run new case
chmod -R 755 $CASEROOT/$MYCASE/
cd $CASEROOT/$MYCASE
# Set the *.xml files or replace them with your files
rm env_conf.xml env_run.xml
cp $CCSMROOT/lxf_spinup_files/env_conf.xml ./
cp $CCSMROOT/lxf_spinup_files/env_run.xml ./

# configure the case
./configure '-case' > ${MYCASE}.setuplog
# build the case
./${MYCASE}.${MYMACH}.build > ${MYCASE}.buildlog
# run the case
rm ${MYCASE}.${MYMACH}.submit
cp $CCSMROOT/lxf_spinup_files/${MYCASE}.${MYMACH}.submit ./
./${MYCASE}.${MYMACH}.submit
# copy the results into exp_output directory
# mkdir $EXPOUT/$CASE
# cp $DOUTDIR/$CASE/lnd/hist/${CASE}.clm2.h0.*.nc $EXPOUT/$CASE
