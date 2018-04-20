#!/bin/sh

  for ((i=3; i<=50; i=i+1 ));

    do
    
    (
      cd /wps/home/linxf/CLM/cesm_code/cesm1_0_3/spinupExp/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN
	  ./PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN.lxfpc.clean_build;
      ./configure -cleanall;
	  echo '&clm_inparm'>user_nl_clm;
	  echo 'hist_nhtfrq = 1'>>user_nl_clm;
	  echo 'hist_mfilt  = 1200'>>user_nl_clm;
	  echo 'fpftcon = "/wps/home/linxf/CLM/cesm_indata/lnd/clm2/pftdata/pft-physiology.c110425.CN-QYZ.nc"'>>user_nl_clm;
      echo 'finidat = "/wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive/spinup_temp/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_N-QYZ_ICN.clm2.r.2007-01-01-00000.nc"'>>user_nl_clm;
	  echo '/'>>user_nl_clm;
      ./configure '-case';
      ./PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN.lxfpc.build;
      ./PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN.lxfpc.run;
      cd /wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive/spinup_temp;
      rm PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_N-QYZ_ICN.clm2.r.2007-01-01-00000.nc;
      cp -f /wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN/rest/2007-01-01-00000/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_N-QYZ_ICN.clm2.r.2007-01-01-00000.nc ./;
      mkdir PTCLM_$i;
      cp -r /wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN/lnd/hist/* ./PTCLM_$i;
      cd /wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_archive/;
      rm -rf PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN;
      cd /wps/home/linxf/CLM/cesm_outdata/cesm1_0_3/clm_run;
      rm -rf PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN;
      cd /wps/home/linxf/CLM/cesm_code/cesm1_0_3/spinupExp/PTCLM_OBSdata2005_halfhour_20170814_CN-QYZ_ICN_CN-QYZ_ICN

    );
    
    done
