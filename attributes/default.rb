#
# Cookbook Name:: bind
# Attributes:: default
#
# Copyright 2016, Julien 'Lta' BALLET
# Copyright 2011, Eric G. Wolfe
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

# Set platform/version specific directories and settings
case node['platform_family']
when 'debian'
  default['named']['packages'] = %w(bind9 bind9utils)
  default['named']['sysconfdir'] = '/etc/bind'
  default['named']['vardir'] = '/var/cache/bind'
  default['named']['service_name'] = 'bind9'
  default['named']['user'] = 'bind'
  default['named']['group'] = 'bind'
  default['named']['conf_file'] = "#{node['named']['sysconfdir']}/named.conf"
  default['named']['options_file'] = "#{node['named']['sysconfdir']}/named.options"
  default['named']['rndc-key'] = "#{node['named']['sysconfdir']}/rndc.key"
end

default['named']['zones'] = []
default['named']['zone_files'] = []
default['named']['acls'] = []
default['named']['views'] = []



# Files which should be included in named.conf
default['named']['included_files'] = %w(named.rfc1912.zones named.options)

# These are var files referenced by our rfc1912 zone and root hints (named.ca) zone
default['named']['var_cookbook_files'] = %w(named.empty named.ca named.loopback named.localhost)

# This an array of masters, or servers which you transfer from.
default['named']['masters'] = []

# This an array of forwarders, or servers which I will query upstream
default['named']['forwarders'] = []

# Zones that should use the forwarders
default['named']['forwardzones'] = []

# Set DNS NAMED Server Clause options
default['named']['server'] = {}

# Boolean to turn off/on IPV6 support
default['named']['ipv6_listen'] = false

# If this is a virtual machine, you need to use urandom as
# any VM does not have a real CMOS clock for entropy.
if node.key?('virtualization') && node['virtualization']['role'] == 'guest'
  default['named']['rndc_keygen'] = 'rndc-confgen -a -r /dev/urandom'
else
  default['named']['rndc_keygen'] = 'rndc-confgen -a'
end

# These two attributes are used to load named ACLs from data bags.
# The search key is the "acl-role", and defaults to internal-acl
default['named']['acl-role'] = 'internal-acl'
default['named']['acls'] = []

# This attribute is for setting site-specific Global option lines
# to be included in the template.
default['named']['options'] = []

# Set an override at the role, or environment level for the named.zones array.
# named.zonetype is used in the named.conf file for configured zones.
default['named']['zonetype'] = 'slave'

# This attribute enable logging
default['named']['enable_log'] = false
default['named']['log_file_versions'] = 2
default['named']['log_file_size'] = '1m'
default['named']['log_file'] = '/var/log/bind9/query.log'
default['named']['log_options'] = []

# These are for enabling statistics-channel on a TCP port.
default['named']['statistics-channel'] = true
default['named']['statistics-port'] = 8080

case node['platform_family']
when 'rhel'
  default['named']['statistics-channel'] if node['platform_version'].to_i <= 5
end
