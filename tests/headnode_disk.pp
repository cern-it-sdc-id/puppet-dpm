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
class{"dpm::head_disknode":
   configure_repos	=> true,
   configure_default_pool => true,
   configure_default_filesystem => true,
   disk_nodes => ['localhost'],
   localdomain => "cern.ch",
   db_pass => "MYSQLPASS",
   mysql_root_pass => "MYSQLROOT",
   token_password   => 'thetokenpasswordshouldbelongerthan32chars',
   xrootd_sharedkey => "A32TO64CHARACTERKEYTESTTESTTESTTEST",
   site_name => "CERN_DPM_TEST",
   new_installation => false,
   volist  => ['dteam', 'lhcb'],
   mountpoints => ['/srv/dpm','/srv/dpm/01'],
   pools => ['mypool:100M'],
   filesystems => ["mypool:${fqdn}:/srv/dpm/01"],
   dpmmgr_uid => "500",
   configure_dome => true,
   configure_domeadapter => true,
   configure_legacy => false,
}
