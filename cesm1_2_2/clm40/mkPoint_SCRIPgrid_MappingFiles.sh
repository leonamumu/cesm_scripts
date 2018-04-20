#------------------------------------------------------------------------#
# File Name: Create_SCRIPgrid_MappingFiles.sh
# Author: Xiaofeng Lin
# mail: linxiaofeng.whu@gmail.com
# Created Time: Thu 22 Jun 2017 11:25:48 AM CST
#------------------------------------------------------------------------#

#!/bin/bash
# create grid and mapping data
# preparing for the surface data creating
export CCSMROOT=/wps/home/linxf/CLM/cesm_code/cesm1_2_2
export CSMDATA=/wps/home/linxf/CLM/cesm_indata
export MYDATA=/wps/home/linxf/CLM/cesm_indata
export GRIDNAME=1x1pt_CN-QYZ
export LAT=26.7457
export LON=115.0622
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
./mknoocnmap.pl -p $LAT,$LON -n $GRIDNAME
echo "Create SCRIP grid datasets successfully"

# step2 Create mapping files for use by mksurfdata_map with mkmapdata
# modify mkmapdata.sh file
cd $CCSMROOT/models/lnd/clm/tools/shared/mkmapdata
grep -q "CSMDATA=$MYDATA" mkmapdata.sh
if [[ $? -eq 0 ]]; then
	echo "CSMDATA has been set correctly in mkmapdata.sh file"
else
	sed -i -e 's|CSMDATA=/glade/p/cesm/cseg/inputdata|CSMDATA=/wps/home/linxf/CLM/cesm_indata|' mkmapdata.sh
fi
# create mapping files using bignode
if [ ! -f "create_mappingFiles.sh" ]; then
	touch "create_mappingFiles.sh"
fi
echo '#!/bin/bash' > create_mappingFiles.sh
echo "$CCSMROOT/models/lnd/clm/tools/shared/mkmapdata/mkmapdata.sh -r $GRIDNAME -f $GRIDFILE -t regional -p clm4_0" >> create_mappingFiles.sh
chmod 755 create_mappingFiles.sh
bsub -e ID_%J.err -o ID_%J.out -q bignode -n 1 ./create_mappingFiles.sh
echo "Create mapping files successfully"
