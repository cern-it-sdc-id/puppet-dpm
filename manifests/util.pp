class dpm::util {
	define add_dpm_voms {
            class{"voms::${title}":}
        }

	define add_dpm_pool ($legacy = true) {
            $pooldef = split($title,":")
            $poolname = $pooldef[0]
            $poolsize = $pooldef[1]
            if $legacy {
                lcgdm::dpm::pool{$poolname:
                    def_filesize => $poolsize
         	}
            } else {
                dmlite::dpm::pool{$poolname:}
            }
        }
	
         define add_dpm_fs ($legacy = true){
             $fsdef  = split($title,":")
             $pool   = $fsdef[0]
             $server = $fsdef[1]
             $fspath = $fsdef[2]
             if $legacy {
                 Lcgdm::Dpm::Pool[$pool]->
                 lcgdm::dpm::filesystem{$title:
                     ensure  => present,
                     pool    => $pool,
                     server  => $server,
                     fs      => $fspath
                }
             } else {
  	         Dmlite::Dpm::Pool[$pool] ->
                 dmlite::dpm::filesystem{$title:     
                     ensure  => present,
                     pool    => $pool,
                     server  => $server,
                     fs      => $fspath
                 }
             }
        }

}
