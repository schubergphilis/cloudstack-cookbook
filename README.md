Description
===========

Installs and configures CloudStack

Requirements
============

* mysql

Attributes
==========

* cloudstack/db_server_role, The role used to search for CloudStack database server

Usage
=====

This cookbook can install and configure an entire Apache CloudStack setup. The recipes for the usage server, the agent are straight forward, just assign the to a server and they will install the necessary packages.

The management server itself is slightly more involved. It requires you to setup a role on a mysql server, cs_database_server by default and set the database recipe on that server. The management server recipe will search for that role and use the discovered credentials to configure itself using the cloud-setup-database script.

A typical setup with this cookbook could use three roles.

* cs_management_server with the recipes management, usageserver and cloudbridge
* cs_database_server with the recipe database
* cs_kvm_hypervisor with the agent recipe

Known Issues
============

* This cookbook is not able to configure CloudStack in a cluster configuration.
* Only works with CloudStack version 4.1 or later. 

License and Authors
===================

Copyright:: 2013 Author's  
Author:: Roeland Kuipers <rkuipers@schubergphilis.com>  
Author:: Sander Botman <sbotman@schubergphilis.com>  
Author:: Hugo Trippaers <htrippaers@schubergphilis.com>  

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

