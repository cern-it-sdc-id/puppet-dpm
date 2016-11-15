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

class{'dpm::headnode':
   configure_repos		=> true,
   configure_default_pool	=> true,
   configure_default_filesystem => true,
   localdomain                  => 'cern.ch',
   db_user			=> 'dpmdbuser',
   db_pass                      => 'PASS',
   db_host 			=> 'localhost',
   mysql_root_pass              => 'ROOTPASS',
   token_password               => 'kwpoMyvcusgdbyyws6gfcxhntkLoh8jilwivnivel',
   xrootd_sharedkey             => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                    => 'CNR_DPM_TEST',
   volist                       => [dteam, lhcb],
   new_installation		=> false,
   pools 			=> ['mypool:100M'],
   filesystems 			=> ["mypool:${fqdn}:/srv/dpm/01"],
   disk_nodes                   => ['dpmdisk01.cern.ch'],
   configure_dome		=> true,
   configure_domeadapter        => true,
   dpmmgr_uid                   => 500,
}
