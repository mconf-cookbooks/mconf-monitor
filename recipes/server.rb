#
# Cookbook Name:: mconf-monitor
# Recipe:: server
# Author:: Felipe Cecagno (<felipe@mconf.org>)
# Author:: Mauricio Cruz (<brcruz@gmail.com>)
#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

include_recipe "mconf-monitor::json_interface"
include_recipe "mconf-monitor::nagios_plugins"

logrotate_app "rotate-nagios" do
  cookbook "logrotate"
  path "#{node['nagios']['log_dir']}/nagios.log"
  options [ "missingok", "compress", "copytruncate", "notifempty" ]
  frequency node['mconf-monitor']['nagios']['logrotate']['frequency']
  rotate node['mconf-monitor']['nagios']['logrotate']['rotate']
  size node['mconf-monitor']['nagios']['logrotate']['size']
  create "644 nagios nagios"
end

logrotate_app "rotate-apache" do
  cookbook "logrotate"
  path "#{node['apache']['log_dir']}/apache_*.log"
  options [ "missingok", "compress", "copytruncate", "notifempty" ]
  frequency node['mconf-monitor']['apache']['logrotate']['frequency']
  rotate node['mconf-monitor']['apache']['logrotate']['rotate']
  size node['mconf-monitor']['apache']['logrotate']['size']
  create "644 root root"
end
