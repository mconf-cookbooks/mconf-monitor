#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

default['mconf']['tools']['dir'] = "/var/mconf/tools"
default['mconf']['instance_type'] = "bigbluebutton"
default['mconf']['interval'] = 20
default['mconf']['nagios']['dir'] = "#{node['mconf']['tools']['dir']}/nagios"
# it should be a list, ex: ["server1","server2"]
# if nil, it will use the attribute node['nsca_handler']['nsca_server'] instead
default['mconf']['monitor']['servers'] = nil
# if you want to force restart on every execution, set normal['mconf']['monitor']['force_restart'] = true
default['mconf']['monitor']['force_restart'] = false

# this is to store the topology
default['mconf']['topology'] = {}
default['mconf']['remount_topology'] = false
default['mconf']['as_lookup'] = nil
default['mconf']['nuttcp']['enabled'] = false

default['psutil']['version'] = "0.5.1"

# cpu, memory and disk are expressed in %
default['mconf']['performance_report']['cpu_warning'] = 70
default['mconf']['performance_report']['cpu_critical'] = 90
default['mconf']['performance_report']['memory_warning'] = 70
default['mconf']['performance_report']['memory_critical'] = 90
default['mconf']['performance_report']['disk_warning'] = 80
default['mconf']['performance_report']['disk_critical'] = 90
# network is expressed in kbps
default['mconf']['performance_report']['network_warning'] = 40000
default['mconf']['performance_report']['network_critical'] = 70000

# logrotate options
# by default keeps one log file per week, during half a year
default['mconf-monitor']['nagios']['logrotate']['frequency'] = 'weekly'
default['mconf-monitor']['nagios']['logrotate']['rotate']    = 26
default['mconf-monitor']['nagios']['logrotate']['size']      = nil

# by default keeps one log file per week, during half a year
default['mconf-monitor']['apache']['logrotate']['frequency'] = 'weekly'
default['mconf-monitor']['apache']['logrotate']['rotate']    = 26
default['mconf-monitor']['apache']['logrotate']['size']      = nil
