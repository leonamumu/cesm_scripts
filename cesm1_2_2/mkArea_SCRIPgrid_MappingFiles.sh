#------------------------------------------------------------------------#
# File Name: mkArea_SCRIPgrid_MappingFiles.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# create grid and mapping data
# preparing for the surface data creating
# beijing 39.43-41.06,115.41,117.51
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export MYDATA=/wps/home/linxf/CLM/cesm_indata
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

# step1 Create SCRIP grid datasets
cd $CCSMROOT/models/lnd/clm/tools/shared/mkmapgrids
# modify mkscripgrid.ncl as follows
# ; lonCenters = fspan( (lonW + delX/2.d0), (lonE - delX/2.d0), nx)
# ; latCenters = fspan( (latS + delY/2.d0), (latN - delY/2.d0), ny)
#   lonCenters = lonW + delX/2.d0
#   latCenters = latS + delY/2.d0
grep -q "lonCenters = lonW + delX/2.d0" mkscripgrid.ncl
if [[ $? -eq 0 ]]; then
	echo "mkscripgrid.ncl file is ok"
else
	sed -i -e 's|lonCenters = fspan( (lonW + delX/2.d0), (lonE - delX/2.d0), nx)|lonCenters = lonW + delX/2.d0|' mkscripgrid.ncl
	sed -i -e 's|latCenters = fspan( (latS + delY/2.d0), (latN - delY/2.d0), ny)|latCenters = latS + delY/2.d0|' mkscripgrid.ncl
fi
# run mknoocnmap.pl to create SCRIP grid data files(land and ocean)
cd $CCSMROOT/models/lnd/clm/tools/shared/mkmapdata
./mknoocnmap.pl -p $CENLAT,$CENLON -n $GRIDNAME -dy $DY -ny $NY -dx $DX -nx $NX
if [ $? -eq 0 ]
then
	echo "Create SCRIP grid dataset successfully"
else
	echo "Create SCRIP grid dataset failed"
fi

# step2 Create mapping files for use by mksurfdata_map with mkmapdata
# modify mkmapdata.sh file
cd $CCSMROOT/models/lnd/clm/tools/shared/mkmapdata
grep -q "CSMDATA=/wps/home/linxf/CLM/cesm_indata" mkmapdata.sh
if [[ $? -eq 0 ]]; then
	echo "CSMDATA has been set correctly in mkmapdata.sh file"
else
	sed -i -e 's|CSMDATA=/glade/p/cesm/cseg/inputdata|CSMDATA=/wps/home/linxf/CLM/cesm_indata|' mkmapdata.sh
fi
# create mapping files using bignode
if [ ! -f "create_mappingFiles.sh" ]; then
	touch "create_mappingFiles.sh"
fi
echo '#!/bin/bash' > createArea_mappingFiles.sh
echo "$CCSMROOT/models/lnd/clm/tools/shared/mkmapdata/mkmapdata.sh -r $GRIDNAME -f $GRIDFILE -t regional" >> createArea_mappingFiles.sh
chmod 755 create_mappingFiles.sh
bsub -e ID_%J.err -o ID_%J.out -q bignode -n 1 ./createArea_mappingFiles.sh
if [ $? -eq 0 ]
then
	echo "Create mapping files successfully"
else
	echo "Create mapping files failed"
fi
