class dpm::util {
	define add_dpm_voms {
        	class{"voms::${title}":}
        }

	define add_dpm_pool {
                $pooldef = split($title,":")
                $poolname = $pooldef[0]
                $poolsize = $pooldef[1]
         	lcgdm::dpm::pool{$poolname:
                	def_filesize => $poolsize
         	}
        }
	
	 define add_dpm_fs {
                $fsdef  = split($title,":")
                $pool   = $fsdef[0]
                $server = $fsdef[1]
                $fspath = $fsdef[2]
                lcgdm::dpm::filesystem{$title:
                	ensure  => present,
                	pool    => $pool,
                	server  => $server,
               		fs      => $fspath
                }
        }

}
