# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
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


class{'dpm::headnode':
   localdomain                  => 'cern.ch',
   db_user			=> 'dpmdbuser',
   db_pass                      => 'PASS',
   db_host 			=> 'dpmdb01.cern.ch',
   disk_nodes                   => ['dpm-disk01.cern.ch'],
   local_db 			=> false,
   dpmmgr_uid                   => 500,
   mysql_root_pass              => 'MYSQLROOT',
   token_password               => 'kwpoMyvcusgdbyyws6gfcxhntkLoh8jilwivnivel',
   xrootd_sharedkey             => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                    => 'CNR_DPM_TEST',
   volist                       => ['dteam', 'lhcb','km3net.org'],
   new_installation 		=> true,
   configure_repos		=> true,
}

class{'voms::km3net':}
