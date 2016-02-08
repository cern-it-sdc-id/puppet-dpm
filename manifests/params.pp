class dpm::params {
  $configure_vos =  hiera('dpm::params::configure_vos', true)
  $configure_gridmap =  hiera('dpm::params::configure_gridmap', true)
  $configure_bdii =  hiera('dpm::params::configure_bdii', true)
  $configure_firewall = hiera('dpm::params::configure_firewall', true)
  $configure_default_pool = hiera('dpm::params::configure_default_pool',false)
  $configure_default_filesystem = hiera('dpm::params::configure_default_filesystem',false)
  

  #cluster options
  $headnode_fqdn =  hiera('dpm::params::headnode_fqdn', $::fqdn)
  $disk_nodes =  hiera('dpm::params::disk_nodes','')
  $localdomain =  hiera('dpm::params::localdomain',undef)
  $webdav_enabled = hiera('dpm::params::webdav_enabled',true)
  $memcached_enabled = hiera('dpm::params::webdav_enabled',true)
  $local_db = hiera('dpm::params::local_db',true)

  #dpmmgr user options
  $dpmmgr_uid =  hiera('dpm::params::dpmmgr_uid',151)
  $dpmmgr_gid =  hiera('dpm::params::dpmmgr_gid',151)

  #DB/Auth options
  $db_user =  hiera('dpm::params::db_user','dpmmgr')
  $db_pass =  hiera('dpm::params::db_pass',undef)
  $db_host =  hiera('dpm::params::db_host','localhost')
  $mysql_root_pass =  hiera('dpm::params::mysql_root_pass',undef)
  $token_password =  hiera('dpm::params::token_password',undef)
  $xrootd_sharedkey =  hiera('dpm::params::xrootd_sharedkey',undef)
  $xrootd_use_voms = hiera('dpm::params::xrootd_use_voms',true)

  #VOs parameters
  $volist =  hiera('dpm::params::volist',[])
  $groupmap =  hiera('dpm::params::groupmap',{
        'vomss://voms.hellasgrid.gr:8443/voms/dteam?/dteam'                 => 'dteam',
      'vomss://voms2.hellasgrid.gr:8443/voms/dteam?/dteam'                 => 'dteam',
      })

  #Debug Flag
  $debug = hiera('dpm::params::debug',false)

  #Xrootd Federations
  $dpm_xrootd_fedredirs = hiera('dpm::params::dpm_xrootd_fedredirs',{})

  #Xrootd Monitoring
  $xrd_report = hiera('dpm::params::xrd_report',undef)
  $xrootd_monitor = hiera('dpm::params::xrootd_monitor',undef)

  $site_name = hiera('dpm::params::site_name',undef)
}
