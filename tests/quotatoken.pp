class{'dmlite::shell':}

dmlite::dpm::quotatoken{"/dpm/cern.ch/home/dteam":
 ensure => 'absent',
 pool => 'mypool',
 desc => 'test token',
 size => '1GB',
 groups => ['dteam'],
}
