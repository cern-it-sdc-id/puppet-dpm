#
#class based on the dpm wiki example
#
class dpm::headnode (
    $configure_vos =  $dpm::params::configure_vos,
    $configure_gridmap =  $dpm::params::configure_gridmap,

    #cluster options
    $headnode_fqdn =  $dpm::params::headnode_fqdn,
    $disk_nodes =  $dpm::params::disk_nodes,
    $localdomain =  $dpm::params::localdomain,
    $webdav_enabled = $dpm::params::webdav_enabled,
    $memcached_enabled = $dpm::params::memcached_enabled,

    #dpmmgr user options
    $dpmmgr_uid =  $dpm::params::dpmmgr_uid,

    #DB/Auth options
    $db_user =  $dpm::params::db_user,
    $db_pass =  $dpm::params::db_pass,
    $mysql_root_pass =  $dpm::params::mysql_root_pass,
    $token_password =  $dpm::params::token_password,
    $xrootd_sharedkey =  $dpm::params::xrootd_sharedkey,
    $xrootd_use_voms =  $dpm::params::xrootd_use_voms,

    #VOs parameters
    $volist =  $dpm::params::volist,
    $groupmap =  $dpm::params::groupmap,

    #Debug Flag
    $debug = $dpm::params::debug,

    #XRootd federations
    $dpm_xrootd_fedredirs = $dpm::params::dpm_xrootd_fedredirs,
  
  )inherits dpm::params {

   #XRootd monitoring parameters
    if($dpm::params::xrd_report){
      $xrd_report = $dpm::params::xrd_report
    }else{
      $xrd_report  = undef
    }

    if($dpm::params::xrootd_monitor){
        $xrootd_monitor = $dpm::params::xrootd_monitor
    }else{
      $xrootd_monitor = undef
    }
    
    if($dpm::params::site_name){
        $site_name = $dpm::params::site_name
    }else{
      $site_name = undef
    }

    #
    # Set inter-module dependencies
    #
    Class[Mysql::Server] -> Class[Lcgdm::Ns::Service]

    Class[Lcgdm::Dpm::Service] -> Class[Dmlite::Plugins::Adapter::Install]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Gridftp]

    if($memcached_enabled){
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Dav::Service]
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Gridftp]
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Srm]
    }


    #
    # MySQL server setup - disable if it is not local
    #
    class{"mysql::server":
      root_password   => "${mysql_root_pass}"
    }


    class{"lcgdm::base":
            uid     => $dpmmgr_uid,
          }


    #
    # DPM and DPNS daemon configuration.
    #
    class{"lcgdm":
      dbflavor => "mysql",
      dbuser   => "${db_user}",
      dbpass   => "${db_pass}",
      dbhost   => "localhost",
      domain   => "${localdomain}",
      volist   => $volist,
    }

    #
    # RFIO configuration.
    #
    class{"lcgdm::rfio":
      dpmhost => "${::fqdn}",
    }

    #
    # Entries in the shift.conf file, you can add in 'host' below the list of
    # machines that the DPM should trust (if any).
    #
    lcgdm::shift::trust_value{
      "DPM TRUST":
        component => "DPM",
        host      => "${disk_nodes}";
      "DPNS TRUST":
        component => "DPNS",
        host      => "${disk_nodes}";
      "RFIO TRUST":
        component => "RFIOD",
        host      => "${disk_nodes}",
        all       => true
    }
    lcgdm::shift::protocol{"PROTOCOLS":
      component => "DPM",
      proto     => "rfio gsiftp http https xroot"
    }


    #
    # VOMS configuration (same VOs as above): implements all the voms classes in the vo list
    #
    #WARN!!!!: in 3.4 collect has been renamed "map"
    #if($configure_vos){
    #  class{ $volist.map |$vo| {"voms::$vo"}:}
    #  #Create the users: no pool accounts just one user per group
    #  ensure_resource('user', values($groupmap), {ensure => present})
    #}


    if($configure_gridmap){
      #setup the gridmap file
      lcgdm::mkgridmap::file {"lcgdm-mkgridmap":
        configfile   => "/etc/lcgdm-mkgridmap.conf",
        localmapfile => "/etc/lcgdm-mapfile-local",
        logfile      => "/var/log/lcgdm-mkgridmap.log",
        groupmap     => $groupmap,
        localmap     => {"nobody" => "nogroup"}
      }
    }

    #
    # dmlite configuration.
    #
    class{"dmlite::head":
      token_password => "${token_password}",
      mysql_username => "${db_user}",
      mysql_password => "${db_pass}",
    }

    #
    # Frontends based on dmlite.
    #
    if($webdav_enabled){
      Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav]
      Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Dav]
      Class[Dmlite::Install] ~> Class[Dmlite::Dav::Config]

      class{"dmlite::dav":}
    }
    class{"dmlite::srm":}
    class{"dmlite::gridftp":
      dpmhost => "${::fqdn}"
    }


    # The XrootD configuration is a bit more complicated and
    # the full config (incl. federations) will be explained here:
    # https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Xroot/PuppetSetup

    #
    # The simplest xrootd configuration.
    #
    class{"xrootd::config":
      xrootd_user  => $dpmmgr_user,
      xrootd_group => $dpmmgr_user,
    }

    class{"dmlite::xrootd":
          nodetype              => [ 'head' ],
          domain                => "${localdomain}",
          dpm_xrootd_debug      => $debug,
          dpm_xrootd_sharedkey  => "${xrootd_sharedkey}",
          xrootd_use_voms       => $xrootd_use_voms,
          dpm_xrootd_fedredirs => $dpm_xrootd_fedredirs,
          xrd_report => $xrd_report,
          xrootd_monitor => $xrootd_monitor,
          site_name => $site_name
   }

   if($memcached_enabled)
   {
     class{"memcached":
       max_memory => 512,
     }
     ->
     class{"dmlite::plugins::memcache":
       expiration_limit => 600,
       posix            => 'on',
       func_counter     => 'on',
     }
   }



}
