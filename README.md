puppet-dpm module
======

The puppet-dpm module has been developed to ease the set up of a DPM installation via puppet.

It can be used to set up different DPM installations :

 - DPM Headnode ( with or without a local MySql DB)
 - DPM Disknode
 - DPM Head+Disk Node 
 
Dependencies
=====

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

 Installation
=====

The puppet-dpm module can be installed from puppetforge via

```
puppet module install puppet-dpm
```

  Usage
=====
 
 
