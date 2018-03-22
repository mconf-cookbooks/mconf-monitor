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
  path "#{node['nagios']['log_dir']}/*.log"
  options [ "missingok", "compress", "copytruncate", "notifempty", "dateext" ]
  frequency node['mconf-monitor']['nagios']['logrotate']['frequency']
  rotate node['mconf-monitor']['nagios']['logrotate']['rotate']
  size node['mconf-monitor']['nagios']['logrotate']['size']
  create "644 nagios nagios"
end

old_rotate_apache = '/etc/logrotate.d/rotate-apache'
file old_rotate_apache do
  action :delete
  only_if { File.exist?(old_rotate_apache) }
end

# This overrides the config created when apache was installed
# So it's partially a copy of the packaged config, plus a few
# customizations (frequency, rotate, size, 'dateext')
logrotate_app 'apache2' do
  cookbook 'logrotate'
  path ["#{node['apache']['log_dir']}/*.log"]
  options ['missingok', 'compress', 'delaycompress', 'notifempty', 'sharedscripts', 'dateext']
  frequency node['mconf-monitor']['apache']['logrotate']['frequency']
  rotate node['mconf-monitor']['apache']['logrotate']['rotate']
  size node['mconf-monitor']['apache']['logrotate']['size']
  postrotate <<-EOF
    if /etc/init.d/apache2 status > /dev/null ; then \\
      /etc/init.d/apache2 reload > /dev/null; \\
    fi;
  EOF
  prerotate <<-EOF
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then \\
      run-parts /etc/logrotate.d/httpd-prerotate; \\
    fi;
  EOF
  create "640 root adm"
end
