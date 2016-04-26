class dpm::head_disknode (
    $configure_vos =  $dpm::params::configure_vos,
    $configure_gridmap =  $dpm::params::configure_gridmap,
    $configure_bdii = $dpm::params::configure_bdii,
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

    #xrootd monitoring
    $xrd_report = $dpm::params::xrd_report,
    $xrootd_monitor = $dpm::params::xrootd_monitor,

    $site_name = $dpm::params::site_name,

    #New DB installation vs upgrade
    $new_installation = $dpm::params::new_installation,

)inherits dpm::params {
   
   validate_array($disk_nodes)
   validate_bool($new_installation)
   validate_array($volist)
  
   $disk_nodes_str=join($disk_nodes,' ')

    #
    # Set inter-module dependencies
    #

    Class[lcgdm::dpm::service] -> Class[dmlite::plugins::adapter::install]
    Class[lcgdm::ns::config] -> Class[dmlite::srm::service]
    Class[dmlite::head] -> Class[dmlite::plugins::adapter::install]
    Class[dmlite::plugins::adapter::install] ~> Class[dmlite::srm]
    Class[dmlite::plugins::adapter::install] ~> Class[dmlite::gridftp]
    Class[dmlite::plugins::mysql::install] ~> Class[dmlite::srm]
    Class[dmlite::plugins::mysql::install] ~> Class[dmlite::gridftp]
    Class[fetchcrl::service] -> Class[xrootd::config]

    if($memcached_enabled){
       Class[dmlite::plugins::memcache::install] ~> Class[dmlite::dav::service]
       Class[dmlite::plugins::memcache::install] ~> Class[dmlite::gridftp]
       Class[dmlite::plugins::memcache::install] ~> Class[dmlite::srm]
    }


    #
    # MySQL server setup 
    #
    if ($local_db) {
      Class[mysql::server] -> Class[lcgdm::ns::service]

      $override_options = {
      	'mysqld' => {
            'max_connections'    => '1000',
            'query_cache_size'   => '256M',
            'query_cache_limit'  => '1MB',
            'innodb_flush_method' => 'O_DIRECT',
            'innodb_buffer_pool_size' => '1000000000',
            'bind-address' => '0.0.0.0',
          }
     }
      
      class{'mysql::server':
    	service_enabled   => true,
        root_password => $mysql_root_pass,
	override_options => $override_options,
        create_root_user => $new_installation,
        }
    } else {
      class{'mysql::server':
        service_enabled   => false,
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
      mysqlrootpass => $mysql_root_pass,
      domain   => $localdomain,
      volist   => $volist,
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
        host      => "$disk_nodes_str $headnode_fqdn";
      'DPNS TRUST':
        component => 'DPNS',
        host      => "$disk_nodes_str $headnode_fqdn";
      'RFIO TRUST':
        component => 'RFIOD',
        host      => "$disk_nodes_str $headnode_fqdn",
        all       => true
    }
    lcgdm::shift::protocol{'PROTOCOLS':
      component => 'DPM',
      proto     => 'rfio gsiftp http https xroot'
    }

    if($configure_vos){
      $newvolist = reject($volist,'\.')
      dpm::util::add_dpm_voms{$newvolist:}
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
        require => Lcgdm::Mkgridmap::File['lcgdm-mkgridmap'],
 	creates => '/etc/lcgdm-mapfile',
      }
    }

    #
    # dmlite configuration.
    #
    class{'dmlite::head':
      token_password => $token_password,
      mysql_username => $db_user,
      mysql_password => $db_pass,
      mysql_host     => $db_host,
    }

    #
    # Frontends based on dmlite.
    #
    if($webdav_enabled){
      Class[dmlite::plugins::adapter::install] ~> Class[dmlite::dav]
      Class[dmlite::plugins::mysql::install] ~> Class[dmlite::dav]
      Class[dmlite::install] ~> Class[dmlite::dav::config]
      Dmlite::Plugins::Adapter::Create_config <| |> -> Class[dmlite::dav::install]

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
       listen_ip => '127.0.0.1',
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
    Class[bdii::install] -> Class[lcgdm::bdii::dpm]
    Class[lcgdm::bdii::dpm] -> Class[bdii::service]

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
    Class[lcgdm::dpm::service] -> Lcgdm::Dpm::Pool <| |>
    lcgdm::dpm::pool{'mypool':
    def_filesize => '100M'
  }
  }
  #
  #
  # You can define your filesystems
  #
  if ($configure_default_filesystem) {
    Class[lcgdm::base::config] ->
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

}
