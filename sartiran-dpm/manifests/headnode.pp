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

    #dpmmgr user options
    $dpmmgr_user = $dpm::params::dpmmgr_user,
    $dpmmgr_uid =  $dpm::params::dpmmgr_uid,
    $dpmmgr_gid =  $dpm::params::dpmmgr_gid,

    #DB/Auth options
    $db_user =  $dpm::params::db_user,
    $db_pass =  $dpm::params::db_pass,
    $mysql_root_pass =  $dpm::params::mysql_root_pass,
    $token_password =  $dpm::params::token_password,
    $xrootd_sharedkey =  $dpm::params::xrootd_sharedkey,

    #VOs parameters
    $volist =  $dpm::params::volist,
    $groupmap =  $dpm::params::groupmap,

    #Debug Flag
    $debug = $dpm::params::debug,

    #XRootd federations
    $dpm_xrootd_fedredirs = $dpm::params::dpm_xrootd_fedredirs,
  
  )inherits dpm::params {

    #some packages that should be present if we want things to run

    ensure_resource('package',['openssh-server','openssh-clients','vim-minimal','cronie','policycoreutils','selinux-policy'],{ensure => present,before => Class[Lcgdm::Base::Config]})

    #
    # Set inter-module dependencies
    #
    Class[Mysql::Server] -> Class[Lcgdm::Ns::Service]

    Class[Lcgdm::Dpm::Service] -> Class[Dmlite::Plugins::Adapter::Install]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Gridftp]

    if($webdav_enabled){
      Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav]
      Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Dav]
    }

    

    #
    # MySQL server setup - disable if it is not local
    #
    class{"mysql::server":
      root_password   => "${mysql_root_pass}"
    }


    class{"lcgdm::base::config":
            user    => $dpmmgr_user,
            uid     => $dpmmgr_uid,
            gid     => $dpmmgr_gid,
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
    if($configure_vos){
      class{ $volist.map |$vo| {"voms::$vo"}:}
      #Create the users: no pool accounts just one user per group
      ensure_resource('user', values($groupmap), {ensure => present})
    }
    

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
      xrootd_use_voms	=> false,
      dpm_xrootd_fedredirs => $dpm_xrootd_fedredirs,
    }
}
