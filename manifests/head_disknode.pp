#
#class based on the dpm wiki example
#
class dpm::head_disknode (
    $configure_vos =  $dpm::params::configure_vos,
    $configure_gridmap =  $dpm::params::configure_gridmap,
    $configure_bdii = $dpm::params::configure_bdii,
    $configure_firewall = $dpm::params::configure_firewall,
    $configure_default_pool = $dpm::params::configure_default_pool,
    $configure_default_filesystem = $dpm::params::configure_default_filesystem,

    #cluster options
    $local_db = $dpm::params::local_db,
    $headnode_fqdn =  $dpm::params::headnode_fqdn,
    $disk_nodes =  $dpm::params::disk_nodes,
    $localdomain =  $dpm::params::localdomain,
    $webdav_enabled = $dpm::params::webdav_enabled,
    $memcached_enabled = $dpm::params::memcached_enabled,

    #dpmmgr user options
    $dpmmgr_uid =  $dpm::params::dpmmgr_uid,
    $dpmmgr_gid =  $dpm::params::dpmmgr_gid,

    #DB/Auth options
    $db_user =  $dpm::params::db_user,
    $db_pass =  $dpm::params::db_pass,
    $db_host =  $dpm::params::db_host,
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

    $site_name = $dpm::params::site_name,

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
    
    #
    # Set inter-module dependencies
    #

    Class[Lcgdm::Dpm::Service] -> Class[Dmlite::Plugins::Adapter::Install]
    Class[Lcgdm::Ns::Config] -> Class[Dmlite::Srm::Service]
    Class[Dmlite::Head] -> Class[Dmlite::Plugins::Adapter::Install]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Gridftp]
    Class[fetchcrl::service] -> Class[Xrootd::Config]

    if($memcached_enabled){
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Dav::Service]
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Gridftp]
       Class[Dmlite::Plugins::Memcache::Install] ~> Class[Dmlite::Srm]
    }


    #
    # MySQL server setup 
    #
    if ($local_db) {
      Class[Mysql::Server] -> Class[Lcgdm::Ns::Service]
      
      class{'mysql::server':
    service_enabled   => true,
        root_password => $mysql_root_pass
          }
    }
   
    #
    # DPM and DPNS daemon configuration.
    #
    class{'lcgdm':
      dbflavor => 'mysql',
      dbuser   => $db_user,
      dbpass   => $db_pass,
      dbhost   => $db_host,
      domain   => $localdomain,
      volist   => $volist,
      dbmanage => $local_db,
      uid      => $dpmmgr_uid,
      gid      => $dpmmgr_gid,
    }

    #
    # RFIO configuration.
    #
    class{'lcgdm::rfio':
      dpmhost => $::fqdn,
    }

    #
    # Entries in the shift.conf file, you can add in 'host' below the list of
    # machines that the DPM should trust (if any).
    #
    lcgdm::shift::trust_value{
      'DPM TRUST':
        component => 'DPM',
        host      => $disk_nodes;
      'DPNS TRUST':
        component => 'DPNS',
        host      => $disk_nodes;
      'RFIO TRUST':
        component => 'RFIOD',
        host      => $disk_nodes,
        all       => true
    }
    lcgdm::shift::protocol{'PROTOCOLS':
      component => 'DPM',
      proto     => 'rfio gsiftp http https xroot'
    }

    if($configure_vos){
      define add_dpm_voms {
        class{"voms::${title}":}
      }
      add_dpm_voms {$volist:}
    }

    if($configure_gridmap){
      #setup the gridmap file
      lcgdm::mkgridmap::file {'lcgdm-mkgridmap':
        configfile   => '/etc/lcgdm-mkgridmap.conf',
        localmapfile => '/etc/lcgdm-mapfile-local',
        logfile      => '/var/log/lcgdm-mkgridmap.log',
        groupmap     => $groupmap,
        localmap     => {'nobody'        => 'nogroup'}
      }
      
       exec{'/usr/sbin/edg-mkgridmap --conf=/etc/lcgdm-mkgridmap.conf --safe --output=/etc/lcgdm-mapfile':
        require => Lcgdm::Mkgridmap::File['lcgdm-mkgridmap']
      }
    }

    #
    # dmlite configuration.
    #
    class{'dmlite::head':
      token_password => $token_password,
      mysql_username => $db_user,
      mysql_password => $db_pass,
    }

    #
    # Frontends based on dmlite.
    #
    if($webdav_enabled){
      Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav]
      Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Dav]
      Class[Dmlite::Install] ~> Class[Dmlite::Dav::Config]
      Dmlite::Plugins::Adapter::Create_config <| |> -> Class[Dmlite::Dav::Install]

      class{'dmlite::dav':}
    }
    class{'dmlite::srm':}
    class{'dmlite::gridftp':
      dpmhost => $::fqdn
    }


    # The XrootD configuration is a bit more complicated and
    # the full config (incl. federations) will be explained here:
    # https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Xroot/PuppetSetup

    #
    # The simplest xrootd configuration.
    #
    class{'xrootd::config':
      xrootd_user  => $dpmmgr_user,
      xrootd_group => $dpmmgr_user,
    }

    class{'dmlite::xrootd':
          nodetype             => [ 'head','disk' ],
          domain               => $localdomain,
          dpm_xrootd_debug     => $debug,
          dpm_xrootd_sharedkey => $xrootd_sharedkey,
          xrootd_use_voms      => $xrootd_use_voms,
          dpm_xrootd_fedredirs => $dpm_xrootd_fedredirs,
          xrd_report           => $xrd_report,
          xrootd_monitor       => $xrootd_monitor,
          site_name            => $site_name
   }

   if($memcached_enabled)
   {
     class{'memcached':
       max_memory => 512,
     }
     ->
     class{'dmlite::plugins::memcache':
       expiration_limit => 600,
       posix            => 'on',
       func_counter     => 'on',
     }
   }

   if ($configure_bdii)
   {
    #bdii installation and configuration with default values
    include('bdii')
    Class[Bdii::Install] -> Class[Lcgdm::Bdii::Dpm]
    Class[Lcgdm::Bdii::Dpm] -> Class[Bdii::Service]

    # GIP installation and configuration
    class{'lcgdm::bdii::dpm':
       sitename => $site_name,
       vos      => $volist,
    }

   }
  
   #limit conf

   $limits_config = {
    '*' => {
      nofile => { soft => 65000, hard => 65000 },
      nproc  => { soft => 65000, hard => 65000 },
    }
   }
   class{'limits':
    config    => $limits_config,
    use_hiera => false
  }

  #pools configuration
  #
  if ($configure_default_pool) {
  Class[Lcgdm::Dpm::Service] -> Lcgdm::Dpm::Pool <| |>
  lcgdm::dpm::pool{'mypool':
    def_filesize => '100M'
  }
  }
  #
  #
  # You can define your filesystems
  #
  if ($configure_default_filesystem) {
    Class[Lcgdm::Base::Config] ->
     file {
     '/srv/dpm':
     ensure => directory,
     owner => 'dpmmgr',
     group => 'dpmmgr',
     mode =>  '0775';
     '/srv/dpm/01':
     ensure => directory,
     owner => 'dpmmgr',
     group => 'dpmmgr',
     seltype => 'httpd_sys_content_t',
     mode => '0775';
   }
    ->
    lcgdm::dpm::filesystem {"${fqdn}-myfsname":
    pool   => 'mypool',
    server => $fqdn,
    fs     => '/srv/dpm'
   }
  }

  if ($configure_firewall) {
  #
  # The firewall configuration
  #
  firewall{'050 allow http and https':
    proto  => 'tcp',
    dport  => [80, 443],
    action => 'accept'
  }
  firewall{'050 allow rfio':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '5001',
    action => 'accept'
  }
  firewall{'050 allow rfio range':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '20000-25000',
    action => 'accept'
  }
  firewall{'050 allow gridftp control':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '2811',
    action => 'accept'
  }
  firewall{'050 allow gridftp range':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '20000-25000',
    action => 'accept'
  }
  firewall{'050 allow srmv2.2':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '8446',
    action => 'accept'
  }
  firewall{'050 allow xrootd':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '1095',
    action => 'accept'
  }
  firewall{'050 allow cmsd':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '1094',
    action => 'accept'
  }

  firewall{'050 allow DPNS':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '5010',
    action => 'accept'
  }
  firewall{'050 allow DPM':
    state  => 'NEW',
    proto  => 'tcp',
    dport  => '5015',
    action => 'accept'
  }
    }
}
