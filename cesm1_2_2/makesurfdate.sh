#!/bin/bash
#set latitude longitude
export GRIDNAME=1x1_JL
export CDATE='170309'
export CENLON=125.5
export CENLAT=44
export DX=4
export NX=4
export DY=3
export NY=3
export CCSMROOT=/wps/home/esmnjnu/SML/CESM1.2.2
# cd the directory of mknoocnmap
cd $CCSMROOT/models/lnd/clm/tools/shared/mkmapdata/
#make SCRIP grid file
./mknoocnmap.pl  -p $CENLAT,$CENLON -n $GRIDNAME -dy $DY -ny $NY -dx $DX -nx $NX
export MAPFILE=$CCSMROOT/models/lnd/clm/tools/shared/mkmapdata/map_${GRIDNAME}_noocean_to_${GRIDNAME}_nomask_aave_da_${CDATE}.nc
export GRIDFILE=$CCSMROOT/models/lnd/clm/tools/shared/mkmapgrids/SCRIPgrid_${GRIDNAME}_nomask_c${CDATE}.nc
#make surfdata 
./mkmapdata.sh -r $GRIDNAME -f $GRIDFILE -t regional
#creat domain file
cd ../../../../../../tools/mapping/gen_domain_files
export OCNDOM=domain.ocn_noocean.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean.nc
./gen_domain -m $MAPFILE -o $OCNDOM -l $ATMDOM
export GENDOM_PATH=$CCSMROOT/tools/mapping/gen_domain_files
#make surface dataset
cd ../../../models/lnd/clm/tools/clm4_5/mksurfdata_map
./mksurfdata.pl -r usrspec -usr_gname $GRIDNAME -usr_gdate $CDATE -crop -hirespft -y 2000