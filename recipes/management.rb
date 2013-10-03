#
# Cookbook Name:: cloudstack
# Recipe:: management
#
# Copyright 2013, Author's.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::client"


#
# Install the cloudstack-management package and dependencies
#
%w{ cloudstack-management
}.each {|component|
  yum_package component do
    action :install
  end
}


#
# Install vhd-util, this file is required but not distributed with CloudStack
#
directory "/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver" do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
end

cookbook_file "/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util" do
  source "vhd-util"
  owner 'root'
  group 'root'
  mode 0755
end


#
# Symlinks, normally craeted by cloudstack-setup-management
#
link "/etc/cloudstack/management/tomcat6.conf" do
  to "/etc/cloudstack/management/tomcat6-nonssl.conf"
end

link "/etc/cloudstack/management/server.xml" do
  to "/etc/cloudstack/management/server-nonssl.xml"
end

link "/etc/cloudstack/management/log4j.xml" do
  to "/etc/cloudstack/management/log4j-cloud.xml"
end


#
# Set nproc limits for user cloud
#
template node['cloudstack']['nproc_limit_file'] do
  source 'nproc_limits.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables :user          => node['cloudstack']['username'],
            :hard	   => node['cloudstack']['nproc_limit_hard'],
            :soft          => node['cloudstack']['nproc_limit_soft'],
            :recipe_file   => (__FILE__).to_s.split("cookbooks/").last,
            :template_file => source.to_s
end


#
# Set nofile limits for user cloud
#
template node['cloudstack']['nofile_limit_file'] do
  source 'nofile_limits.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables :user          => node['cloudstack']['username'],
            :hard          => node['cloudstack']['nofile_limit_hard'],
            :soft          => node['cloudstack']['nofile_limit_soft'],
            :recipe_file   => (__FILE__).to_s.split("cookbooks/").last,
            :template_file => source.to_s
end


#
# Flag to indicate management server has been configured
#
ruby_block "cs_management_config_complete" do
  block do
    node.set['cloudstack']['cs_management_config_complete'] = true
    node.save
  end
  action :nothing
end

#
# Flag to indicate the database has been configured
#
ruby_block "cs_database_setup_complete" do
  block do
    node.set['cloudstack']['cs_database_setup_complete'] = true
    node.save
  end
  action :nothing
end
 
#
#  Execution blocks
#
cs_mysql_target_nodedata=search(:node, "roles:#{node['cloudstack']['db_server_role']}").first
cs_mysql_target_name="#{cs_mysql_target_nodedata['hostname']}"
cs_mysql_target_root_password="#{cs_mysql_target_nodedata['mysql']['server_root_password']}"
cs_mysql_target_cloud_password="#{cs_mysql_target_nodedata['cloudstack']['db_password']}"

Log "MYSQL SERVER IS: #{cs_mysql_target_name}"
Log "MYSQL ROOT PASSWORD IS: #{cs_mysql_target_root_password}"
Log "MYSQL CLOUD PASSWORD IS: #{cs_mysql_target_cloud_password}"


#
# Configure the database for first use
# this will load the schema files
#
execute "cs_create_mysql_db" do
  command "cloudstack-setup-databases cloud:#{cs_mysql_target_cloud_password}@#{cs_mysql_target_name} --deploy-as=root:#{cs_mysql_target_root_password}"
  notifies :create, "ruby_block[cs_database_setup_complete]", :immediately
  not_if { (node['cloudstack']['cs_database_setup_complete']) }
end


#
# Rreconfigure the db.properties only
#
execute "cs_management_config_db" do
  command "cloudstack-setup-databases cloud:#{cs_mysql_target_cloud_password}@#{cs_mysql_target_name}"
  notifies :restart, "service[cloudstack-management]"
  notifies :create, "ruby_block[cs_management_config_complete]", :immediately
  not_if { (node['cloudstack']['cs_management_config_complete']) }
end

#
# Enable the service
#
service "cloudstack-management" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
