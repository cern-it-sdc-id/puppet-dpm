# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://puppet.com/docs/puppet/5.0/tests_smoke.html
#

class{'dpm::headnode':
   configure_repos		=> false,
   configure_default_pool	=> false,
   configure_default_filesystem => true,
   localdomain                  => 'cern.ch',
   db_user			=> 'dpmdbuser',
   db_pass                      => 'PASS',
   db_host 			=> 'localhost',
   mysql_root_pass              => 'mysqlroot',
   token_password               => 'thetokenpasswordshouldbelongerthan32chars',
   xrootd_sharedkey             => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                    => 'CNR_DPM_TEST',
   volist                       => [dteam, lhcb],
   new_installation		=> true,
   local_db                     => true,
   pools 			=> ['mypool:100M'],
   filesystems 			=> ["mypool:${fqdn}:/srv/dpm/01"],
   disk_nodes                   => ['dpmdisk01.cern.ch'],
   configure_dome		=> false,
   configure_domeadapter        => false,
   dpmmgr_uid                   => 500,
   configure_legacy             => true,
   host_dn                      => 'your host dn'
}
