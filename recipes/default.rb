#
# Cookbook Name:: bind
# Recipe:: default
#
# Copyright 2016, Julien 'Lta' BALLET
# Copyright 2011, Gerald L. Hevener, Jr, M.S.
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
all_zones = []
forwardzones = []

# # Read ACL objects from data bag.
# # These will be passed to the named.options template
# if Chef::Config['solo'] && !node['bind']['allow_solo_search']
#   Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
# else
#   begin
#     search(:bind, "role:#{node['bind']['acl-role']}") do |acl|
#       node.default['bind']['acls'] << acl
#     end
#   rescue
#     Chef::Log.warn('bind databag not found, assuming ACL is empty.')
#   end
# end

unless node['platform_family'] == 'debian'
  Chef::Log.fail <<-MSG
The named cookbook only supports debian based platforms.

If you want to support other platforms, edit attributes/default.rb
and send a pull request :)
MSG

end
# Install required packages
node['named']['packages'].each do |bind_pkg|
  package bind_pkg
end

[node['named']['sysconfdir'], node['named']['vardir']].each do |named_dir|
  directory named_dir do
    owner node['named']['user']
    group node['named']['group']
    mode 00750
  end
end

# # Create /var/named subdirectories
# %w(data master slaves).each do |subdir|
#   directory "#{node['named']['vardir']}/#{subdir}" do
#     owner node['named']['user']
#     group node['named']['group']
#     mode 00770
#     recursive true
#   end
# end

# Copy localhost (rf1912) zones into place
cookbook_file "#{node['named']['sysconfdir']}/named.rfc1912.zones" do
  owner node['named']['user']
  group node['named']['group']
  mode 00644
end

# Copy /var/named files in place
node['named']['var_cookbook_files'].each do |var_file|
  cookbook_file "#{node['named']['vardir']}/#{var_file}" do
    owner node['named']['user']
    group node['named']['group']
    mode 00644
  end
end

# Create rndc key file, if it does not exist
execute 'rndc-key' do
  command node['named']['rndc_keygen']
  not_if { ::File.exist?(node['named']['rndc-key']) }
end

file node['named']['rndc-key'] do
  owner node['named']['user']
  group node['named']['group']
  mode 00600
  action :touch
end

# # Include zones from external source if set.
# if !node['named']['zonesource'].nil?
#   include_recipe "bind::#{node['named']['zonesource']}2zone"
# else
#   Chef::Log.warn('No zonesource defined, assuming zone names are defined as override attributes.')
# end

# all_zones = node['named']['zones']['attribute'] + node['named']['zones']['databag'] + node['named']['zones']['ldap']
# forwardzones = node['named']['forwardzones']

# Render a template with all our global BIND options and ACLs
template node['named']['options_file'] do
  owner node['named']['user']
  group node['named']['group']
  mode 00644
  variables(
    acls: lazy { node['named']['acls'] },
  )
  helpers Named::ConfHelpers
end

# Render our template with role zones, or returned results from
# zonesource recipe
template node['named']['conf_file'] do
  owner node['named']['user']
  group node['named']['group']
  mode 00644
  variables(
    zones: lazy { node['named']['zones'] },
    views: lazy { node['named']['views'] },
  )
  helpers Named::ConfHelpers
  notifies :run, 'execute[named-checkconf]', :immediately
  notifies :run, 'execute[failsafe-checkconf]', :immediately
end

# Run named-checkconf as a sanity check on configuration, and start service
execute 'named-checkconf' do
  command "/usr/sbin/named-checkconf -z #{node['named']['conf_file']}"
  action :nothing
  notifies :enable, 'service[bind]', :immediately
  notifies :start, 'service[bind]', :immediately
  only_if { ::File.exist?('/usr/sbin/named-checkconf') }
end

# Start service if named-checkconf does not exist
execute 'failsafe-checkconf' do
  command 'true'
  action :nothing
  notifies :enable, 'service[bind]', :immediately
  notifies :start, 'service[bind]', :immediately
  not_if { ::File.exist?('/usr/sbin/named-checkconf') }
end

service 'bind' do
  service_name node['named']['service_name']
  supports reload: true, status: true
  action :nothing
  subscribes :reload, resources("template[#{node['named']['options_file']}]"), :delayed
  subscribes :reload, resources('execute[named-checkconf]',
                                'execute[failsafe-checkconf]'), :delayed
  only_if { ::File.exist?(node['named']['options_file']) && ::File.exist?(node['named']['conf_file']) }
end
