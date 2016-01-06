#
#class based on the dpm wiki example
#
class dpm::disknode (
  $configure_vos =  $dpm::params::configure_vos,
  $configure_gridmap =  $dpm::params::configure_gridmap,
  $configure_firewall = $dpm::params::configure_firewall,

  #cluster options
  $headnode_fqdn =  $dpm::params::headnode_fqdn,
  $disk_nodes =  $dpm::params::disk_nodes,
  $localdomain =  $dpm::params::localdomain,
  $webdav_enabled = $dpm::params::webdav_enabled,

  #dpmmgr user options
  $dpmmgr_uid =  $dpm::params::dpmmgr_uid,
  $dpmmgr_gid =  $dpm::params::dpmmgr_gid,

  #Auth options
  $token_password =  $dpm::params::token_password,
  $xrootd_sharedkey =  $dpm::params::xrootd_sharedkey,
  $xrootd_use_voms =  $dpm::params::xrootd_use_voms,
  
  #VOs parameters
  $volist =  $dpm::params::volist,
  $groupmap =  $dpm::params::groupmap,
  
  #Debug Flag
  $debug = $dpm::params::debug,
  
  )inherits dpm::params {

    Class[Lcgdm::Base::Install] -> Class[Lcgdm::Rfio::Install]
    if($webdav_enabled){
      Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav::Service]
    }
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]

    # lcgdm configuration.
    #
    class{'lcgdm::base':
      uid => $dpmmgr_uid,
      gid => $dpmmgr_gid,
    }

    
    class{'lcgdm::ns::client':
      flavor  => 'dpns',
      dpmhost => $headnode_fqdn
    }

    #
    # RFIO configuration.
    #
    class{'lcgdm::rfio':
      dpmhost => $headnode_fqdn,
    }
    
    #
    # Entries in the shift.conf file, you can add in 'host' below the list of
    # machines that the DPM should trust (if any).
    #
    lcgdm::shift::trust_value{
      'DPM TRUST':
        component => 'DPM',
        host      => "${headnode_fqdn} ${disk_nodes}";
      'DPNS TRUST':
        component => 'DPNS',
        host      => "${headnode_fqdn} ${disk_nodes}";
      'RFIO TRUST':
        component => 'RFIOD',
        host      => "${headnode_fqdn} ${disk_nodes}",
        all       => true
    }
    lcgdm::shift::protocol{'PROTOCOLS':
      component => 'DPM',
      proto     => 'rfio gsiftp http https xroot'
    }

    if($configure_vos){
      dpm::util::add_dpm_voms {$volist:}
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
    }
    
    
    #
    # dmlite plugin configuration.
    class{'dmlite::disk':
      token_password => $token_password,
      dpmhost        => $headnode_fqdn,
      nshost         => $headnode_fqdn,
    }
    
    #
    # dmlite frontend configuration.
    #
    if($webdav_enabled){
      class{'dmlite::dav':}
    }
    
    class{'dmlite::gridftp':
      dpmhost => $headnode_fqdn
    }

    # The XrootD configuration is a bit more complicated and
    # the full config (incl. federations) will be explained here:
    # https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Xroot/PuppetSetup
    
    #
    # The simplest xrootd configuration.
    #
    class{'xrootd::config':
      xrootd_user  => $dpmmgr_user,
      xrootd_group => $dpmmgr_user
    }
    
    class{'dmlite::xrootd':
      nodetype             => [ 'disk' ],
      domain               => $localdomain,
      dpm_xrootd_debug     => $debug,
      dpm_xrootd_sharedkey => $xrootd_sharedkey,
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
  }

    
}
                                                                                                    
