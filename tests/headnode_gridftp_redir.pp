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
   localdomain                  => 'cern.ch',
   db_user			=> 'dpmdbuser',
   db_pass                      => 'PASS',
   db_host 			=> 'localhost',
   local_db 			=> true,
   dpmmgr_uid                   => 500,
   disk_nodes                   => ['dpm-disk01.cern.ch'],
   mysql_root_pass              => 'MYSQLROOT',
   token_password               => 'kwpoMyvcusgdbyyws6gfcxhntkLoh8jilwivnivel',
   xrootd_sharedkey             => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                    => 'CNR_DPM_TEST',
   volist                       => [dteam, lhcb],
   gridftp_redirect		=> 1;
}
