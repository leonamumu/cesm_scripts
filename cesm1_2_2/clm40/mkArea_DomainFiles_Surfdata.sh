#------------------------------------------------------------------------#
# File Name: mkArea_DomainFiles_Surfdata.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 29 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# create surfdata
# preparing for the surface data creating
# beijing 39.43-41.06,115.41,117.51
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export Macros=/wps/home/linxf/CLM/cesm_code/cesm1_2_2/build_files
export GRIDNAME=0.01x0.01_BeiJing
export CENLON=40.18   # the center longitude of area(区域中心点的经度)
export CENLAT=116.41  # the center latitude of area(区域中心点的纬度)
export DX=2           # the longitude span of area(区域经度跨度)
export NX=200         # the grid points of zonal(经向格点数量)
export DY=2           # the latitude span of area(区域纬度跨度)
export NY=200         # the grid points of meridional（纬向格点数量）
export CDATE=`date +%y%m%d`
export GRIDFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapgrids/SCRIPgrid_${GRIDNAME}_nomask_c${CDATE}.nc
export MAPFILE=${CCSMROOT}/models/lnd/clm/tools/shared/mkmapdata/map_${GRIDNAME}_noocean_to_${GRIDNAME}_nomask_aave_da_${CDATE}.nc
export GENDOM_PATH=$MYDATA/share/domains/domain.clm/
export OCNDOM=domain.ocn_noocean.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean.nc

# step3 Create domain dataset
# create Macros file and copy to gen_domain_files/src directory
cd $CCSMROOT/tools/mapping/gen_domain_files/src/
$CCSMROOT/scripts/ccsm_utils/Machines/configure -mach lxfpc -compiler gnu
cp $CCSMROOT/scripts/ccsm_utils/Machines/Macros ./
# modify gen_domain.F90 file
grep -q "nargs = COMMAND_ARGUMENT_COUNT()" gen_domain.F90
if [[ $? -eq 0 ]]; then
	echo "gen_domain.F90 file is ok"
else
	sed -i -e 's|nargs = iargc()|nargs = COMMAND_ARGUMENT_COUNT()|' mkmapdata.sh
fi
# gmake and create domain files
gmake
cd ..
./gen_domain -m $MAPFILE -o $OCNDOM -l $ATMDOM
if [ $? -eq 0 ]
then
	echo "Create domain dataset successfully"
else
	echo "Create domain dataset failed"
fi

# step4 Create surface datasets
cd $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/src
# modify Makefile.common file
grep -q "export NETCDF" Makefile.common
if [[ $? -eq 0 ]]; then
	echo "Makefile.common file is ok"
else
	sed '/LIB_NETCDF=$(NETCDF)/lib/i\export NETCDF=/wps/home/linxf/CLM/CLM4.5_install/software/netcdf-4.3.3.1' Makefile.common
	sed '/INC_NETCDF=$(NETCDF)/include/a\USER_FC=/usr/bin/gfortran\nUSER_CC=usr/bin/gcc' Makefile.common
fi
grep -q "DLINUX -DFORTRANUNDERSCORE -fno-range-check" Makefile.common
if [[ $? -eq 0 ]]; then
	echo "DLINUX -DFORTRANUNDERSCORE -fno-range-check find in the Makefile.common file"
else
	sed -i -e 's|CPPDEF += -DLINUX -DFORTRANUNDERSCORE|CPPDEF += -DLINUX -DFORTRANUNDERSCORE -fno-range-check|' Makefile.common
fi
grep -q 'LDFLAGS := -L$(LIB_NETCDF) -lnetcdf -lnetcdff' Makefile.common
if [[ $? -eq 0 ]]; then
	echo 'LDFLAGS := -L$(LIB_NETCDF) -lnetcdf -lnetcdff find in the Makefile.common file'
else
	sed -i -e 's|LDFLAGS := $(shell $(LIB_NETCDF)/../bin/nf-config --flibs)|LDFLAGS := -L$(LIB_NETCDF) -lnetcdf -lnetcdff|' Makefile.common
fi
gmake
# modify mksurfdata.pl file
cd ..
grep -q "wps/home/linxf/CLM/cesm_indata" mksurfdata.pl
if [[ $? -eq 0 ]]; then
	echo "CSMDATA have been set correct in mksurfdata.pl file"
else
	sed -i -e 's|glade/p/cesm/cseg/inputdata|wps/home/linxf/CLM/cesm_indata|' mksurfdata.pl
fi
# create surfdata files
./mksurfdata.pl -r usrspec -usr_gname $GRIDNAME -usr_gdate $CDATE > log.out
if [ $? -eq 0 ]
then
	echo "Create surface datasets successfully"
else
	echo "Create surface datasets failed"
fi
