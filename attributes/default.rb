default['cloudstack']['username'] = "cloud"

default['cloudstack']['nproc_limit_soft'] = "4096"
default['cloudstack']['nproc_limit_hard'] = "4096"
default['cloudstack']['nproc_limit_file'] = "/etc/security/limits.d/cloud_nproc.conf"

default['cloudstack']['nofile_limit_soft'] = "4096"
default['cloudstack']['nofile_limit_hard'] = "4096"
default['cloudstack']['nofile_limit_file'] = "/etc/security/limits.d/cloud_nofile.conf"

default['cloudstack']['db_password'] = "cloud"
default['cloudstack']['db_server_role'] = "cs_database_server"
