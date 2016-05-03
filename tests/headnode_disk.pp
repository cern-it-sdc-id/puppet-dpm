class voms::km3net {
  voms::client{
'km3net.org':
      servers  => [{server => 'voms02.scope.unina.it',
                    port   => '15005',
                    dn    => '/C=IT/O=INFN/OU=Host/L=Federico II/CN=voms02.scope.unina.it',
                    ca_dn => '/C=IT/O=INFN/CN=INFN CA'
                   }]
 }
}


class{"dpm::head_disknode":
   configure_default_pool => true,
   configure_default_filesystem => true,
   disk_nodes => ['localhost'],
   localdomain => "cern.ch",
   db_pass => "MYSQLPASS",
   mysql_root_pass => "PASS",
   token_password => "TOKEN_PASSWORD",
   xrootd_sharedkey => "A32TO64CHARACTERKEYTESTTESTTESTTEST",
   site_name => "CERN_DPM_TEST",
   volist  => ['dteam', 'lhcb','km3net.org'],
   configure_repos => true,
}

class{'voms::km3net':}
