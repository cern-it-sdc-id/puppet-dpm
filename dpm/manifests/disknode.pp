
    Class[Lcgdm::Base::Install] -> Class[Lcgdm::Rfio::Install]
    if(WEBDAV_ENABLED){
      Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Dav::Service]
    }
    Class[Dmlite::Plugins::Adapter::Install] ~> Class[Dmlite::Gridftp]

    # lcgdm configuration.
    #
    class{"lcgdm::base::config":
      user    => 'dpmmgr',
      uid     => 90,
      gid     => 970,
    }
    class{"lcgdm::base::install":}

    class{"lcgdm::ns::client":
      flavor  => "dpns",
      dpmhost => "HEADNODE_HOST"
    }

    #
    # RFIO configuration.
    #
    class{"lcgdm::rfio":
      dpmhost => "HEADNODE_HOST",
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
    # dmlite plugin configuration.
    class{"dmlite::disk":
      token_password => "DMLITE_TOKEN_PASSWORD",
      dpmhost        => "HEADNODE_HOST",
      nshost         => "HEADNODE_HOST",
    }

    #
    # dmlite frontend configuration.
    #
    if(WEBDAV_ENABLED){
      class{"dmlite::dav":}
    }

    class{"dmlite::gridftp":
      dpmhost => "HEADNODE_HOST"
    }

    # The XrootD configuration is a bit more complicated and
    # the full config (incl. federations) will be explained here:
    # https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Xroot/PuppetSetup

    #
    # The simplest xrootd configuration.
    #
    class{"xrootd::config":
      xrootd_user  => "dpmmgr",
      xrootd_group => "dpmmgr"
    }

    class{"dmlite::xrootd":
      nodetype              => [ 'disk' ],
      domain                => "LOCALDOMAIN",
      dpmhost              => "HEADNODE_HOST",
      nshost             => "HEADNODE_HOST",
      dpm_xrootd_debug      => false,
      dpm_xrootd_sharedkey  => "XROOTD_KEY"
    }


