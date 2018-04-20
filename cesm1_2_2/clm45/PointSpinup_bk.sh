#------------------------------------------------------------------------#
# File Name: SinglePointSpinup.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Wed 28 Jun 2017 08:47:36 PM CST
#------------------------------------------------------------------------#

#!/bin/bash
# SinglePointSpinup
# preparing for the spinup
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export NETCDF=/wps/home/linxf/CLM/CLM4.5_install/software/netcdf-4.3.3.1
export INC_NETCDF=$NETCDF/include
export LIB_NETCDF=$NETCDF/lib
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export USER_FC=gfortran
export USER_CC=gcc
export MYMACH=lxfpc

# spinup simulation for CLM4.5-BGC
cd $CCSMROOT/scripts
export CASE=CLM45BGC_spinup
./create_newcase -case ../spinupExp/$CASE -res f19_g16 -compset I20TRCRUCLM45BGC -mach lxfpc
cd ../spinupExp/$CASE
# Append "-spinup on" to CLM_BLDNML_OPTS
./xmlchange CLM_BLDNML_OPTS="-bgc_spinup on" -append
# The following sets CLM_FORCE_COLDSTART to "on", and run-type to startup (you could also use an editor)
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup
# Make the output history files only annual, by adding the following to the user_nl_clm namelist
echo 'hist_nhtfrq = -8760' >> user_nl_clm
# Now setup
./cesm_setup
# Now build
./${CASE}.build
# The following sets RESUBMIT to 30 times in env_run.xml (you could also use an editor)
# The following sets STOP_DATE,STOP_N and STOP_OPTION to Jan/1/1001, 20, "nyears" in env_run.xml (you could also use an editor)
./xmlchange RESUBMIT=20,STOP_N=50,STOP_OPTION=nyears,STOP_DATE=10010101
# Now run normally
./${CASE}.submit
