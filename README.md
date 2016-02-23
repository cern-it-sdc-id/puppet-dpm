#puppet-dpm module

[![Puppet Forge](http://img.shields.io/puppetforge/v/lcgdm/dpm.svg)](https://forge.puppetlabs.com/lcgdm/xrootd)
[![Build Status](https://travis-ci.org/cern-it-sdc-id/puppet-dpm.svg?branch=master)]([https://travis-ci.org/cern-it-sdc-id/puppet-dpm.svg)


#### Table of Contents

1. [Description](#Description)
2. [Dependencies](#Dependencies)
3. [Installation](#Installation)
4. [Usage](#Usage)
    * [Headnode](#Headnode)
    * [Disknode](#Disknode)
    * [Common configuration](#Common configuration)
5. [Limitations - OS compatibility, etc.](#limitations)


##Description

The puppet-dpm module has been developed to ease the set up of a DPM installation via puppet.

It can be used to set up different DPM installations :

 - DPM Headnode ( with or without a local MySql DB)
 - DPM Disknode
 - DPM Head+Disk Node 
 
##Dependencies


It relies on several puppet modules, some of them developed @ CERN and some others available from third party.

The following modules are needed in order to use this module, and they are automatically installed from puppetforge

 - lcgdm-gridftp 
 - lcgdm-dmlite
 - lcgdm-lcgdm
 - lcgdm-xrootd
 - lcgdm-voms
 - puppetlabs-stdlib
 - puppetlabs-mysql
 - puppetlabs-firewall
 - saz-memcached
 - CERNOps-bdii
 - CERNOps-fetchcrl
 - erwbgy-limits

##Installation


The puppet-dpm module can be installed from puppetforge via

```
puppet module install lcgdm-dpm
```

##Usage


The module folder tests contains some examples, for instance you can set up a DPM box with both HEAD and DISK nodes with the following code snippet

```
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
   volist =>[dteam],
}
```

the same parameters can be configured via hiera ( see the dpm::params class)

Having the code snippet saved in a file ( i.e.  dpm.pp), then it's just neeed to run:

```
puppet apply dpm.pp
```

to have the DPM box installed and configured
 
Please note that it could be needed to run twice the puppet apply command in order to have all the changes correctly applied

###Headnode

The Headnode configuration is performed via the 'dpm::headnode' class or in case of an installation of a Head+Disk node via the 'dpm::head_disknode' class

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
}
```
The parameters descriptions is quite easy to guess from the name.

#### DB configuration

Depending on the DB installation ( local to the headnode or external ) there are different configuration parameters to set:

In case of a local installation the **db_host** parameter should be configured as *localhost* together with the **local_db** parameter set to *true*.
While for an external DB installation the **local_db** parameter should be set to *false*.

**N.B.** the root DB grants for the headnode should be added manually to the DB in case of an external DB installation:

```
GRANT ALL PRIVILEGES ON *.* TO 'root'@'HEADNODE' IDENTIFIED BY 'MYSQLROOT' WITH GRANT OPTION;
```

**N.B.** In case of an upgrade of an existing DPM installation the **new_installation** parameter MUST be set to *false*

#### Cluster  configuration

The Headnode is configured with the Memcache server and the related DPM plugin. In order to disable it the parameter **memcached_enabled** should be set to *false*.

As well for the WedDav frontend, installed and enabled by default but it can be disabled with **webdav_enabled** set to *false*

Other parameters that are enabled by default are:

* **configure_bdii** :  enabled/disabled the configuration of Resource BDII ( default = true)
* **configure_default_pool** : create a default pool, use for testing ( default = false)
* **configure_default_filesystem** : create a default filesytem, use for testing ( default = false)


#### Xrootd  configuration

Teh Xrootd configuration has 

###Disknode

###Common configuration

#### VO list and mapfile

Both Head and Disk nodes should be configured vith the list of the VOs supported and the configuration input to generate the mapfile.

The parameter **volist** is needed to specify the supported VOs, while the **groupmap** parameter specifies how to map VOMS users.By default the *dteam* VO mapping is given, an example for the whole LHC VOs mappings is as follows:

```
groupmap = {
  "vomss://voms2.cern.ch:8443/voms/atlas?/atlas/"            => "atlas",
  "vomss://lcg-voms2.cern.ch:8443/voms/atlas?/atlas/"      => "atlas",
  "vomss://voms2.cern.ch:8443/voms/cms?/cms/"              => "cms", 
  "vomss://lcg-voms2.cern.ch:8443/voms/cms?/cms/"        => "cms",
  "vomss://voms2.cern.ch:8443/voms/lhcb?/lhcb/"              => "lhcb", 
  "vomss://lcg-voms2.cern.ch:8443/voms/lhcb?/lhcb/"        => "lhcb",
  "vomss://voms2.cern.ch:8443/voms/alice?/alice/"             => "alice", 
  "vomss://lcg-voms2.cern.ch:8443/voms/alice?/alice/"      => "alice",
  "vomss://voms2.cern.ch:8443/voms/ops?/ops/"               => "ops", 
  "vomss://lcg-voms2.cern.ch:8443/voms/ops?/ops/"         => "ops",
  "vomss://voms.hellasgrid.gr:8443/voms/dteam?/dteam"  => "dteam",
  "vomss://voms2.hellasgrid.gr:8443/voms/dteam?/dteam"  => "dteam"
}
```

#### Other coonfiguration:

* **configure_vos** : enable/disable the configuration of the VOs ( default = true)
* **configure_gridmap** : enable/disable the configuration of gridmap file ( default = true)
* **configure_firewall** : enable/disable the configuration of the local firewall ( default = true)
* **gridftp_redirect** : enabled/disabled the GridFTP redirection functionality ( default = 0)
* **dpmmgr_uid** and **dpmmgr_gid** : the gid and uid for the dpmmgr user ( default = 151)
* **debug** : enable/disable installation of the debuginfo packages ( default = false)
* 

