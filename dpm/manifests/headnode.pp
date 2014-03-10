    #
    # Set inter-module dependencies
    #
    Class[Mysql::Server] -> Class[Lcgdm::Ns::Service]

    Class[Lcgdm::Dpm::Service] -> Class[Dmlite::Plugins::Adapter::Install]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]
    if(WEBDAV_ENABLED){
            Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav]
        }
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Srm]
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Gridftp]
    if(WEBDAV_ENABLED){
    Class[Dmlite::Plugins::Mysql::Install] ~> Class[Dmlite::Dav]
    }

    #
    # MySQL server setup - disable if it is not local
    #
    class{"mysql::server":
      root_password   => "MYSQL_ROOT_PASS"
    }


    class{"lcgdm::base::config":
            user    => "dpmmgr",
            uid     => 90,
            gid     => 970,
          }


    #
    # DPM and DPNS daemon configuration.
    #
    class{"lcgdm":
      dbflavor => "mysql",
      dbuser   => "dpmmgr",
      dbpass   => "MYSQL_DB_PASS",
      dbhost   => "localhost",
      domain   => "LOCALDOMAIN",
      volist   => VOLIST,
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
        host      => "DISKNODES_LISTHEADNODE_HOST";
      "DPNS TRUST":
        component => "DPNS",
        host      => "DISKNODES_LISTHEADNODE_HOST";
      "RFIO TRUST":
        component => "RFIOD",
        host      => "DISKNODES_LISTHEADNODE_HOST",
        all       => true
    }
    lcgdm::shift::protocol{"PROTOCOLS":
      component => "DPM",
      proto     => "rfio gsiftp http https xroot"
    }


    #
    # dmlite configuration.
    #
    class{"dmlite::head":
      token_password => "DMLITE_TOKEN_PASSWORD",
      mysql_username => "dpmmgr",
      mysql_password => "MYSQL_DB_PASS",
    }

    #
    # Frontends based on dmlite.
    #
    if(WEBDAV_ENABLED){
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
      xrootd_user  => 'dpmmgr',
      xrootd_group => 'dpmmgr',
    }
    class{"dmlite::xrootd":
      nodetype              => [ 'head' ],
      domain                => "LOCALDOMAIN",
      dpm_xrootd_debug      => false,
      dpm_xrootd_sharedkey  => "XROOTD_KEY"
    }
