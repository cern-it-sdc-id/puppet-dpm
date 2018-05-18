#
#class based on the dpm wiki example
#
class dpm::disknode (
  $configure_vos =  $dpm::params::configure_vos,
  $configure_gridmap =  $dpm::params::configure_gridmap,
  $configure_repos = $dpm::params::configure_repos,
  $configure_dome  = $dpm::params::configure_dome,
  $configure_domeadapter = $dpm::params::configure_domeadapter,
  
  #install and configure legacy stask
  $configure_legacy =   $dpm::params::configure_legacy,  

  #repo list
  $repos =  $dpm::params::repos,

  #cluster options
  $headnode_fqdn =  $dpm::params::headnode_fqdn,
  $disk_nodes =  $dpm::params::disk_nodes,
  $localdomain =  $dpm::params::localdomain,
  $webdav_enabled = $dpm::params::webdav_enabled,

  #mount points conf
  $mountpoints = $dpm::params::mountpoints,

  #GridFTP redirection
  $gridftp_redirect = $dpm::params::gridftp_redirect,

  #dpmmgr user options
  $dpmmgr_uid =  $dpm::params::dpmmgr_uid,
  $dpmmgr_gid =  $dpm::params::dpmmgr_gid,
  $dpmmgr_user =  $dpm::params::dpmmgr_user,

  #Auth options
  $token_password =  $dpm::params::token_password,
  $xrootd_sharedkey =  $dpm::params::xrootd_sharedkey,
  $xrootd_use_voms =  $dpm::params::xrootd_use_voms,
  
  #VOs parameters
  $volist =  $dpm::params::volist,
  $groupmap =  $dpm::params::groupmap,
  $localmap = $dpm::params::localmap,

  #Debug Flag
  $debug = $dpm::params::debug,

  #xrootd monitoring
  $xrd_report = $dpm::params::xrd_report,
  $xrootd_monitor = $dpm::params::xrootd_monitor,
  
  #host dn
  $host_dn = $dpm::params::host_dn

  )inherits dpm::params {
  
    validate_array($disk_nodes)
    validate_bool($new_installation)
    validate_array($volist)
    validate_array($mountpoints)
    
    if size($token_password) < 32 {
      fail("token_password should be longer than 32 chars")
    }

    if size($xrootd_sharedkey) < 32  {
      fail("xrootd_sharedkey should be longer than 32 chars and shorter than 64 chars")
    }

    if size($xrootd_sharedkey) > 64  {
      fail("xrootd_sharedkey should be longer than 32 chars and shorter than 64 chars")
    }

    if ($configure_repos){
        create_resources(yumrepo,$repos)
    }
    	
    $disk_nodes_str=join($disk_nodes,' ')

    
    if $configure_legacy {
      Class[lcgdm::base::install] -> Class[lcgdm::rfio::install]
    }

    if(is_integer($gridftp_redirect)){
      $_gridftp_redirect = num2bool($gridftp_redirect)
    }else{
      $_gridftp_redirect = $gridftp_redirect
    }

    if($webdav_enabled){
      if $configure_domeadapter {
        Class[dmlite::plugins::domeadapter::install] ~> Class[dmlite::dav::service]
      } else {
        Class[dmlite::plugins::adapter::install] ~> Class[dmlite::dav::service]
      }
    }
    if $configure_domeadapter {
      Class[dmlite::plugins::domeadapter::install] ~> Class[dmlite::gridftp]
    } else {
      Class[dmlite::plugins::adapter::install] ~> Class[dmlite::gridftp]
    }

    if $configure_legacy {
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
    } else {
      class{'dmlite::base':
        uid => $dpmmgr_uid,
        gid => $dpmmgr_gid,
      }
    }
    if($configure_vos){
      $newvolist = reject($volist,'\.')
      dpm::util::add_dpm_voms {$newvolist:}
    }

    if($configure_gridmap){
      #setup the gridmap file
      lcgdm::mkgridmap::file {'lcgdm-mkgridmap':
        configfile   => '/etc/lcgdm-mkgridmap.conf',
	mapfile      => '/etc/lcgdm-mapfile',
        localmapfile => '/etc/lcgdm-mapfile-local',
        logfile      => '/var/log/lcgdm-mkgridmap.log',
        groupmap     => $groupmap,
        localmap     => $localmap
      }
      exec{'/usr/sbin/edg-mkgridmap --conf=/etc/lcgdm-mkgridmap.conf --safe --output=/etc/lcgdm-mapfile':
        require => Lcgdm::Mkgridmap::File['lcgdm-mkgridmap'],
      	unless => '/usr/bin/test -s /etc/lcgdm-mapfile',
      }
    }
    
    if $configure_legacy {
     Class[lcgdm::base::config] ->
     file {
    	 $mountpoints:
	     ensure => directory,
	     owner => $dpmmgr_user,
	     group => $dpmmgr_user,
	     mode =>  '0775';
   	}
    } else {
      Class[dmlite::base::config] ->
       file {
         $mountpoints:
             ensure => directory,
             owner => $dpmmgr_user,
             group => $dpmmgr_user,
             mode =>  '0775';
        }

    }
    #
    # dmlite plugin configuration.
    class{'dmlite::disk':
      token_password => $token_password,
      dpmhost        => $headnode_fqdn,
      nshost         => $headnode_fqdn,
      enable_dome    => $configure_dome,
      enable_domeadapter => $configure_domeadapter,
      legacy         => $configure_legacy,
      host_dn        => $host_dn,
    }
    
    #
    # dmlite frontend configuration.
    #
    if($webdav_enabled){
      class{'dmlite::dav':}
    }
    
    class{'dmlite::gridftp':
      dpmhost => $headnode_fqdn,
      data_node => $_gridftp_redirect ? {
        true => 1,
        false => 0,
      },
      legacy  => $configure_legacy,
    }

    #
    # The simplest xrootd configuration.
    #
    class{'xrootd::config':
      xrootd_user  => $dpmmgr_user,
      xrootd_group => $dpmmgr_user
    }
    if $xrd_report or $xrootd_monitor {
      class{'dmlite::xrootd':
        nodetype             => [ 'disk' ],
	domain               => $localdomain,
	dpm_xrootd_debug     => $debug,
	dpm_xrootd_sharedkey => $xrootd_sharedkey,
	xrd_report           => $xrd_report,
	xrootd_monitor       => $xrootd_monitor,
        legacy               => $configure_legacy,
        dpm_enable_dome      => $configure_dome,
        dpm_xrdhttp_secret_key => $token_password
      }
     } else {
       class{'dmlite::xrootd':
          nodetype             => [ 'disk' ],
          domain               => $localdomain,
          dpm_xrootd_debug     => $debug,
          dpm_xrootd_sharedkey => $xrootd_sharedkey,
          legacy               => $configure_legacy,
          dpm_enable_dome      => $configure_dome,
          dpm_xrdhttp_secret_key => $token_password
       }
     }

}
                                                                                                    
