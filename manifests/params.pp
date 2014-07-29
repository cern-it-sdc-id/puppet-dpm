class dpm::params {
  $configure_vos =  hiera("dpm::params::configure_vos", false)
  $configure_gridmap =  hiera("dpm::params::configure_gridmap", false)
  $configure_bdii =  hiera("dpm::params::configure_bdii", false)

  #cluster options
  $headnode_fqdn =  hiera("dpm::params::headnode_fqdn", "${::fqdn}")
  $disk_nodes =  hiera("dpm::params::disk_nodes","")
  $localdomain =  hiera("dpm::params::localdomain","")
  $webdav_enabled = hiera("dpm::params::webdav_enabled",false)
  $memcached_enabled = hiera("dpm::params::webdav_enabled",false)

  #dpmmgr user options
  $dpmmgr_uid =  hiera("dpm::params::dpmmgr_uid",1000)

  #DB/Auth options
  $db_user =  hiera("dpm::params::db_user","dpmmgr")
  $db_pass =  hiera("dpm::params::db_pass","")
  $mysql_root_pass =  hiera("dpm::params::mysql_root_pass","")
  $token_password =  hiera("dpm::params::token_password","")
  $xrootd_sharedkey =  hiera("dpm::params::xrootd_sharedkey","")
  $xrootd_use_voms = hiera("dpm::params::xrootd_use_voms",true)

  #VOs parameters
  $volist =  hiera("dpm::params::volist",[])
  $groupmap =  hiera("dpm::params::groupmap",{})

  #Debug Flag
  $debug = hiera("dpm::params::debug",false)

  #Xrootd Federations
  $dpm_xrootd_fedredirs = hiera("dpm::params::dpm_xrootd_fedredirs",{})

  #Xrootd Monitoring
  $xrd_report = hiera("dpm::params::xrd_report",undef)
  $xrootd_monitor = hiera("dpm::params::xrootd_monitor",undef)

  $site_name = hiera("dpm::params::site_name",undef)
}
