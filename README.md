# puppet-dpm module

[![Puppet Forge](http://img.shields.io/puppetforge/v/lcgdm/dpm.svg)](https://forge.puppetlabs.com/lcgdm/xrootd)
[![Build Status](https://travis-ci.org/cern-it-sdc-id/puppet-dpm.svg?branch=master)]([https://travis-ci.org/cern-it-sdc-id/puppet-dpm.svg)


#### Table of Contents

1. [Description](#description)
2. [Dependencies](#dependencies)
3. [Installation](#installation)
4. [Prerequisites](#prerequisites)
5. [Usage](#usage)
    * [Headnode](#headnode)
    * [Disknode](#disknode)
    * [Common configuration](#common-configuration)
6. [Compatibility](#compatibility)


## Description

The puppet-dpm module has been developed to ease the set up of a DPM installation via puppet.

It can be used to set up different DPM installations :

 - DPM Headnode ( with or without a local MySql DB)
 - DPM Disknode
 - DPM Head+Disk Node ( with or without a local MySql DB)
 
## Dependencies


It relies on several puppet modules, some of them developed @ CERN and some others available from third party.

The following modules are needed in order to use this module, and they are automatically installed from puppetforge

 - lcgdm-gridftp 
 - lcgdm-dmlite
 - lcgdm-lcgdm
 - lcgdm-xrootd
 - lcgdm-voms
 - puppetlabs-stdlib
 - puppetlabs-mysql
 - saz-memcached
 - CERNOps-bdii
 - puppet-fetchcrl
 - puppetlabs-firewall

## Installation


The puppet-dpm module can be installed from puppetforge via

```
puppet module install lcgdm-dpm
```

## Prerequisites

The DPM components need an X509 host certificate  (PEM format) to be installed on each host under */etc/grid-security/hostcert.pem* and */etc/grid-security/hostkey.pem*

SELinux must be disabled on every hosts before the installation.

The local firewall is not managed by the module, please check the DPM wiki for information on which ports to open:

https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Admin/InstallationConfigurationPuppetSimple#FirewallConfiguration

##Usage


The module folder tests contains some examples, for instance you can set up a DPM box with both HEAD and DISK nodes with the following code snippet

```
class{'dpm::head_disknode':
   configure_repos		         => true,
   configure_default_pool	      => true,
   configure_default_filesystem  => true,
   localdomain                   => 'cern.ch',
   db_user			               => 'dpmdbuser',
   db_pass                       => 'PASS',
   db_host 			               => 'localhost',
   disk_nodes                    => ['$::fqdn'],
   mysql_root_pass               => 'ROOTPASS',
   token_password                => 'kwpoMyvcusgdbyyws6gfcxhntkLoh8jilwivnivel',
   xrootd_sharedkey              => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                     => 'CNR_DPM_TEST',
   volist                        => [dteam, lhcb],
   new_installation		         => true,
   mountpoints                   => ['/srv/dpm','/srv/dpm/01'],
   pools 			               => ['mypool:100M'],
   filesystems 			         => ["mypool:${fqdn}:/srv/dpm/01"],
}
```

the same parameters can be configured via hiera ( see the dpm::params class)

Having the code snippet saved in a file ( i.e.  dpm.pp), then you just need to run:

```
puppet apply dpm.pp
```

to have the DPM box installed and configured
 
Please note that it could be needed to run twice the puppet apply command in order to have all the changes correctly applied

### Headnode

The Headnode configuration is performed via the **dpm::headnode** class or in case of an installation of a Head+Disk node via the **dpm::head_disknode** class

```
class{"dpm::headnode":
   localdomain                  => 'cern.ch',
   db_user                      => 'dpmdbuser',
   db_pass                      => 'PASS',
   db_host                      => 'localhost',
   disk_nodes                   => ['dpm-disk01.cern.ch'],
   local_db                     => true,
   mysql_root_pass              => 'MYSQLROOT',
   token_password               => 'kwpoMyvcusgdbyyws6gfcxhntkLoh8jilwivnivel',
   xrootd_sharedkey             => 'A32TO64CHARACTERA32TO64CHARACTER',
   site_name                    => 'CNR_DPM_TEST',
   volist                       => [dteam, lhcb],
   new_installation             => true,
   pools 			              => ['mypool:100M'],
   filesystems 			        => ["mypool:${fqdn}:/srv/dpm/01"],
}
```
Each pool and filsystem specified in the pools and filesystems parameter should have the following syntax:

* pools: 'poolname:defaultSize'
* filesystems : 'poolname:servername:filesystem_path'

#### DB configuration

Depending on the DB installation ( local to the headnode or external ) there are different configuration parameters to set:

In case of a local installation the **db_host** parameter should be configured as *localhost* together with the **local_db** parameter set to *true*.
While for an external DB installation the **local_db** parameter should be set to *false*.

**N.B.** the root DB grants for the headnode should be added manually to the DB in case of an external DB installation:

```
GRANT ALL PRIVILEGES ON *.* TO 'root'@'HEADNODE' IDENTIFIED BY 'MYSQLROOT' WITH GRANT OPTION;
```

**N.B.** In case of an upgrade of an existing DPM installation the **new_installation** parameter MUST be set to *false*

the *mysql_override_options* parameter can be used to override the mysql server configuration. In general the values provided by default by the module ( via the $dpm::params::mysql_override_options var ) should be fine.

#### Xrootd  configuration

The basic Xrootd configuration requires only to specifies the **xrootd_sharedkey**, which should be a 32 to 64 char long string, the same for all the cluster.

In order to configure the Xrootd Federations and the Xrootd Monitoring via the parameter **dpm_xrootd_fedredirs**, **xrd_report** and **xrd_monitor** please refer to the DPM-Xrootd puppet guide:

https://svnweb.cern.ch/trac/lcgdm/wiki/Dpm/Xroot/PuppetSetup

#### Other configuration

The Headnode is configured with the Memcache server and the related DPM plugin. In order to disable it the parameter **memcached_enabled** should be set to *false*.

As well for the WedDav frontend, installed and enabled by default but it can be disabled with **webdav_enabled** set to *false*

Other parameters are:

* **configure_bdii** :  enabled/disabled the configuration of Resource BDII ( default = true)
* **configure_default_pool** : create the pools specified in the pools paramter ( default = false)
* **configure_default_filesystem** : create the filesytems  specified in the filesystems parameter ( default = false)

see the Common Configuration section for the rest of configuration options

### Disknode

The Disknode configuration is performed via the **dpm::disknode** class, as follows:

```
class{'dpm::disknode':
   headnode_fqdn                => "HEADNODE",
   disk_nodes                   => ['$::fqdn'],
   localdomain                  => 'cern.ch',
   token_password               => 'TOKEN_PASSWORD',
   xrootd_sharedkey             => 'A32TO64CHARACTERKEYTESTTESTTESTTEST',
   volist                       => [dteam, lhcb],
   mountpoints                  => ['/data','/data/01'],
}
```
In particular the mountpoints var should include the mountpoint paths for the filesystems and the related parent folders. 
See the Common Configuration section for the rest of configuration options

### Common configuration

#### VO list and mapfile

Both Head and Disk nodes should be configured vith the list of the VOs supported and the configuration input to generate the mapfile.

The parameter **volist** is needed to specify the supported VOs, while the **groupmap** parameter specifies how to map VOMS users.By default the *dteam* VO mapping is given, an example for the whole LHC VOs mappings is as follows:

```
groupmap = {
  "vomss://voms2.cern.ch:8443/voms/atlas?/atlas"            => "atlas",
  "vomss://lcg-voms2.cern.ch:8443/voms/atlas?/atlas"      => "atlas",
  "vomss://voms2.cern.ch:8443/voms/cms?/cms"              => "cms", 
  "vomss://lcg-voms2.cern.ch:8443/voms/cms?/cms"        => "cms",
  "vomss://voms2.cern.ch:8443/voms/lhcb?/lhcb"              => "lhcb", 
  "vomss://lcg-voms2.cern.ch:8443/voms/lhcb?/lhcb"        => "lhcb",
  "vomss://voms2.cern.ch:8443/voms/alice?/alice"             => "alice", 
  "vomss://lcg-voms2.cern.ch:8443/voms/alice?/alice"      => "alice",
  "vomss://voms2.cern.ch:8443/voms/ops?/ops"               => "ops", 
  "vomss://lcg-voms2.cern.ch:8443/voms/ops?/ops"         => "ops",
  "vomss://voms.hellasgrid.gr:8443/voms/dteam?/dteam"  => "dteam",
  "vomss://voms2.hellasgrid.gr:8443/voms/dteam?/dteam"  => "dteam"
}
```
**N.B. The VOMS configuraton of VO names with "." is not supported with this class (it will be ignored) therefore each vo of this type should be explicetly added to your manifest as follows:**
``` 
voms{"voms::voname":}

```
**and declared as a class like documented at https://forge.puppet.com/lcgdm/voms** 



#### Other configuration:

* **configure_vos** : enable/disable the configuration of the VOs ( default = true)
* **configure_repos** : configure the yum repositories specified in the repos parameter ( default = false)
* **configure_gridmap** : enable/disable the configuration of gridmap file ( default = true)
* **gridftp_redirect** : enabled/disabled the GridFTP redirection functionality ( default = 0)
* **dpmmgr_user** , **dpmmgr_uid** and  **dpmmgr_gid** : the dpm user name , gid and uid ( default = dpmmgr, 151 and 151)
* **debug** : enable/disable installation of the debuginfo packages ( default = false)

## Compatibility

The module can configure a DPM on SL6 and CentOS7/SL7 

It has been tested with puppet 3 and 4

Mysql 5.1 and 5.5 are supported on SL6

MariaDB 5.5 is supported on C7
