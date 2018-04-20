#!/bin/sh

  for ((i=1; i<=50; i=i+1 ));

    do
    
    (
      
      ./clmpt_arou_spinup_QH-Arou_ICN.shaobpc.clean_build;
      ./configure -cleanall;
      cd /data2/data/sunshaobo/sun_outputdata/clm_archive/spinup_temp;
      rm clmpt_arou_spinup_QH-Arou_ICN.clm2.r.2015-01-01-00000.nc;
      cd /wps/home/chenbz/mymodel_sun/cesm1_0_3/scripts/clmpt_arou_spinup_QH-Arou_ICN;
      cp -f /data2/data/sunshaobo/sun_outputdata/clm_archive/clmpt_arou_spinup_QH-Arou_ICN/rest/2015-01-01-00000/clmpt_arou_spinup_QH-Arou_ICN.clm2.r.2015-01-01-00000.nc /data2/data/sunshaobo/sun_outputdata/clm_archive/spinup_temp;
      echo '&clm_inparm finidat = "/data2/data/sunshaobo/sun_outputdata/clm_archive/spinup_temp/clmpt_arou_spinup_QH-Arou_ICN.clm2.r.2015-01-01-00000.nc" /'>user_nl_clm;
      ./configure '-case';
      ./clmpt_arou_spinup_QH-Arou_ICN.shaobpc.build;
      ./clmpt_arou_spinup_QH-Arou_ICN.shaobpc.run;
      cd /data2/data/sunshaobo/sun_outputdata/clm_archive/spinup_temp;
      mkdir out_$i;
      cp -r /data2/data/sunshaobo/sun_outputdata/clm_archive/clmpt_arou_spinup_QH-Arou_ICN/lnd/hist/* /data2/data/sunshaobo/sun_outputdata/clm_archive/spinup_temp/out_$i;
      cd /data2/data/sunshaobo/sun_outputdata/clm_archive;
      rm -rf clmpt_arou_spinup_QH-Arou_ICN;
      cd /data2/data/sunshaobo/sun_outputdata/clm_run;
      rm -rf clmpt_arou_spinup_QH-Arou_ICN;
      cd /wps/home/chenbz/mymodel_sun/cesm1_0_3/scripts/clmpt_arou_spinup_QH-Arou_ICN

    );
    
    done
