export GRIDNAME=0.5x0.5_JL       #1x1jilin
export CSMDATA=/wps/home/esmnjnu/SML/CESM/inputdata
export CCSMROOT=/wps/home/esmnjnu/SML/CESM1.2.2
export WORKROOT=/wps/home/esmnjnu/SML/CESM
export CDATE=170213
export GENDOM_PATH=$CCSMROOT/tools/mapping/gen_domain_files
export OCNDOM=domain.ocn_noocean.nc
export ATMDOM=domain.lnd.${GRIDNAME}_noocean.nc
export CaseN=BGC_spinup_JL_0.5x0.5 
#Macros所在的目录
export Macros=/wps/home/esmnjnu/SML/Script_ML

#第一次用surfdata的时候，修改其名字，将其复制到相应的位置，之后星号内的部分可以忽略
#将生成的surfdata复制到输入数据文件中，以便建立case读取数据
cp $CCSMROOT/models/lnd/clm/tools/clm4_5/mksurfdata_map/surfdata_${GRIDNAME}_simyr2000_c$CDATE.nc $CSMDATA/lnd/clm2/surfdata_map/surfdata_${GRIDNAME}_simyr2000_cesm1_2_x_clm4_5.nc

#修改domain文件名称 重命名
cd $CCSMROOT/tools/mapping/gen_domain_files/
mv domain.lnd.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.$CDATE.nc domain.lnd.${GRIDNAME}_noocean.nc
mv domain.ocn.domain.lnd.${GRIDNAME}_noocean.nc_domain.ocn_noocean.nc.$CDATE.nc domain.ocn.${GRIDNAME}_noocean.nc

cd $CCSMROOT/scripts
./create_newcase -case $CaseN -res CLM_USRDAT -compset ICRUCLM45BGCCROP -mach userdefined
 cd $CaseN/
 
 
./xmlchange ATM_DOMAIN_PATH=$GENDOM_PATH,LND_DOMAIN_PATH=$GENDOM_PATH,ATM_DOMAIN_FILE=$ATMDOM,LND_DOMAIN_FILE=$ATMDOM
./xmlchange CLM_USRDAT_NAME=$GRIDNAME
./xmlchange MPILIB=mpich,COMPILER=gnu

./xmlchange NTASKS_CPL=10,NTASKS_ROF=10,NTASKS_ICE=10,NTASKS_WAV=10,NTASKS_OCN=10,NTASKS_GLC=10,MAX_TASKS_PER_NODE=10,NTASKS_LND=10,NTASKS_ATM=10
./xmlchange EXEROOT=$WORKROOT/exe_$CaseN  #可修改文件名
./xmlchange RUNDIR=$WORKROOT/run_$CaseN
./xmlchange DIN_LOC_ROOT_CLMFORC=$CSMDATA/atm/datm7 #当使用CRU的compset的时候这项要改
./xmlchange PIO_TYPENAME=pnetcdf

./cesm_setup

cd $Macros
cp Macros  $CCSMROOT/scripts/$CaseN
cd $CCSMROOT/scripts/$CaseN
./$CaseN.build

./xmlchange RESUBMIT=20,STOP_N=50,STOP_OPTION=nyears,STOP_DATE=10010101

#修改run文件，里面有重新提交的命令（resubmit）

bsub -e ee_BGC -o oo_BGC -q rhel6large -n 10 ./$CaseN.run

