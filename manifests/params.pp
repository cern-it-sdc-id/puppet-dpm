class dpm::params {
  $configure_vos =  hiera('dpm::params::configure_vos', true)
  $configure_gridmap =  hiera('dpm::params::configure_gridmap', true)
  $configure_bdii =  hiera('dpm::params::configure_bdii', true)
  $configure_default_pool = hiera('dpm::params::configure_default_pool',false)
  $configure_default_filesystem = hiera('dpm::params::configure_default_filesystem',false)
  $configure_repos =  hiera('dpm::params::configure_repos', false)
  $configure_dome = hiera('dpm::params::configure_dome', false)
  $configure_domeadapter = hiera('dpm::params::configure_domeadapter', false)
  $configure_mountpoints = hiera('dpm::params::configure_mountpoints', true)
  #cluster options
  $headnode_fqdn =  hiera('dpm::params::headnode_fqdn', $::fqdn)
  $disk_nodes =  hiera('dpm::params::disk_nodes',[])
  $localdomain =  hiera('dpm::params::localdomain',undef)
  $webdav_enabled = hiera('dpm::params::webdav_enabled',true)
  $memcached_enabled = hiera('dpm::params::memcached_enabled',true)
  $local_db = hiera('dpm::params::local_db',true)
  $gridftp_redirect =  hiera("dpm::params::gridftp_redirect",0)

  #install and configure legacy stask
  $configure_legacy =  hiera("dpm::params::configure_legacy",true)

  #mountpoints list( for disknode mountpoint conf)
  $mountpoints =  hiera("dpm::params::mountpoints",[])

  #mysql options 
  $mysql_override_options = hiera ("dpm::params::mysql_override_options", {
        'mysqld' => {
            'max_connections'    => '1000',
            'query_cache_size'   => '256M',
            'query_cache_limit'  => '1MB',
            'innodb_flush_method' => 'O_DIRECT',
            'innodb_buffer_pool_size' => '1000000000',
            'bind-address' => '0.0.0.0',
            'innodb_flush_log_at_trx_commit' => '2',
            'innodb_doublewrite' => '0',
            'innodb_support_xa' => '0',
	    'innodb_thread_concurrency' => '8',
            'innodb_log_buffer_size' => '8M',
            'max_connect_errors' => '4294967295'
          }
        })


  #dpmmgr user options
  $dpmmgr_uid =  hiera('dpm::params::dpmmgr_uid',151)
  $dpmmgr_gid =  hiera('dpm::params::dpmmgr_gid',151)
  $dpmmgr_user = hiera('dpm::params::dpmmgr_user','dpmmgr')

  #DB/Auth options
  $db_user =  hiera('dpm::params::db_user','dpmmgr')
  $db_pass =  hiera('dpm::params::db_pass',undef)
  $db_host =  hiera('dpm::params::db_host','localhost')
  $db_manage = hiera('dpm::params::db_manage',true) 
  $dpm_db  =  hiera('dpm::params::dpm_db','dpm_db')
  $ns_db   =  hiera('dpm::params::ns_db','cns_db')
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
  $localmap =  hiera('dpm::params::localmap',{'nobody'        => 'nogroup'})
  #Debug Flag
  $debug = hiera('dpm::params::debug',false)

  #xrootd checksum
  $configure_dpm_xrootd_checksum =  hiera('dpm::params:configure_dpm_xrootd_checksum',false)
   
  #Xrootd TPC x509 delegation
  $configure_dpm_xrootd_delegation = hiera('dpm::params:configure_dpm_xrootd_delegation',false)
  #Xrootd Federations
  $dpm_xrootd_fedredirs = hiera('dpm::params::dpm_xrootd_fedredirs',{})

  #Xrootd Monitoring
  $xrd_report = hiera('dpm::params::xrd_report',undef)
  $xrootd_monitor = hiera('dpm::params::xrootd_monitor',undef)

  $site_name = hiera('dpm::params::site_name',undef)

  $new_installation = hiera('dpm::params::new_installation',true)

  #admin dn( needed for http replication/drain)
  $admin_dn = hiera('dpm::params::admin_dn', '') 
  #host dn
  $host_dn = hiera('dpm::params::host_dn', '')
  #pools and filesystems
  $pools = hiera('dpm::params::pools',[])
  $filesystems = hiera('dpm::params::filesystems',[])
 
  #repos 
  $repos = hiera('dpm::params::repos', {
    'epel' => {
      'descr'    => 'Extra Packages for Enterprise Linux add-ons',
      'baseurl'  => "http://linuxsoft.cern.ch/epel/${lsbmajdistrelease}/\$basearch",
      'gpgcheck' => 0,
      'enabled'  => 1,
      'protect'  => 1,
     },
    'EGI-trustanchors' => {
      'descr'    => 'EGI-trustanchors',
      'baseurl'  => 'http://repository.egi.eu/sw/production/cas/1/current/',
      'gpgcheck' => 0,
      'enabled'  => 1,
    },
    'wlcg' => {
      'descr'    => 'WLCG Repository',
      'baseurl'  => "http://linuxsoft.cern.ch/wlcg/sl6/\$basearch",
      'protect'  => 1,
      'enabled'  => 1,
      'priority' => 20,
      'gpgcheck' => 0,
    }
   }
   )
}
