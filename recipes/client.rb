#
# Cookbook Name:: mconf-monitor
# Recipe:: client
# Author:: Felipe Cecagno (<felipe@mconf.org>)
# Author:: Mauricio Cruz (<brcruz@gmail.com>)
#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

# if node['mconf']['monitor']['servers'] is set, it will use it, otherwise it 
# will use the nsca servers from nsca_handler
if node['mconf']['monitor']['servers']
  monitoring_servers = node['mconf']['monitor']['servers']
else
  monitoring_servers = node['nsca_handler']['nsca_server']
end
activate_performance_report = monitoring_servers and not monitoring_servers.empty?

include_recipe "nsca"
include_recipe "python::default"

python_pip "psutil" do
  version node['psutil']['version']
  if activate_performance_report
    notifies :stop, "service[performance_report]", :delayed
    notifies :start, "service[performance_report]", :delayed
  end
end

%w{ git-core python-dev python-argparse }.each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe "bigbluebutton::load-properties"

directory node['mconf']['nagios']['dir'] do
  owner node['mconf']['user']
  recursive true
end

# performance reporter template creation
template "performance_report upstart" do
    path "/etc/init/performance_report.conf"
    source "performance_report.conf.erb"
    mode "0644"
    variables(
      lazy {{
        :hostname => get_nsca_hostname(),
        :app_dir => node['mconf']['nagios']['dir'],
        :log_dir => node['mconf']['log']['dir'],
        :interval => node['mconf']['interval'],
        :cpu_warning => node['mconf']['performance_report']['cpu_warning'],
        :cpu_critical => node['mconf']['performance_report']['cpu_critical'],
        :memory_warning => node['mconf']['performance_report']['memory_warning'],
        :memory_critical => node['mconf']['performance_report']['memory_critical'],
        :disk_warning => node['mconf']['performance_report']['disk_warning'],
        :disk_critical => node['mconf']['performance_report']['disk_critical'],
        :network_warning => node['mconf']['performance_report']['network_warning'],
        :network_critical => node['mconf']['performance_report']['network_critical']
      }}
    )
    if activate_performance_report
      notifies :stop, "service[performance_report]", :delayed
      notifies :start, "service[performance_report]", :delayed
    end
end

template "#{node['mconf']['nagios']['dir']}/reporter.sh" do
    source "reporter.sh.erb"
    mode 0755
    owner node['mconf']['user']
    variables({
      :nsca_server => monitoring_servers,
      :nsca_dir => node['nsca']['dir'],
      :nsca_config_dir => node['nsca']['config_dir'],
      :nsca_timeout => node['nsca']['timeout']
    })
    action :create
  if activate_performance_report
    notifies :stop, "service[performance_report]", :delayed
    notifies :start, "service[performance_report]", :delayed
  end
end

cookbook_file "#{node['mconf']['nagios']['dir']}/performance_report.py" do
    source "performance_report.py"
    mode 0755
    owner node['mconf']['user']
    action :create
    if activate_performance_report
      notifies :stop, "service[performance_report]", :delayed
      notifies :start, "service[performance_report]", :delayed
    end
end

# performance reporter service definition
service "performance_report" do
    provider Chef::Provider::Service::Upstart
    supports :restart => true, :start => true, :stop => true
    if activate_performance_report
      if node['mconf']['monitor']['force_restart']
        action [ :enable, :restart ]
        node['mconf']['monitor']['force_restart'] = false
      else
        action [ :enable, :start ]
      end
    else
      action [ :disable, :stop ]
    end
end
