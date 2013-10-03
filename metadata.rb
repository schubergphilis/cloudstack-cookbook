maintainer       "Roeland Kuipers"
maintainer_email "rkuipers@schubergphilis.com"
license          "Apache license v2.0"
description      "Installs/Configures CloudStack"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.9.99"
recipe           "cloudstack::agent", "Installs the CloudStack Agent package"
recipe           "cloudstack::cloudbridge", "Installs the CloudStack awsapi package"
recipe           "cloudstack::database", "Prepares a mysql database for CloudStack management server"
recipe           "cloudstack::management", "Installs and configures the CloudStack management server"
recipe           "cloudstack::usageserver", "Install and configures the CloudStack usage server"


depends "mysql"

attribute "cloudstack/db_server_role",
  :display_name => "CloudStack database server role",
  :description => "The role used by the management server recipe to search for the database server",
  :default => "cs_database_server"

