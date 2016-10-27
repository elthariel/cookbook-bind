#
# Resource representing a Bind9 zone file
#
include Named::Helpers

# The main zone info, used to generate SOA
property :name, String, name_property: true
property :primary_ns, String
property :hostmaster, String
property :serial, [NilClass, String], default: nil

# named.conf options
property :type, String, default: 'master'
#property :forwarders, String, default: ''

# File level options
property :ttl, [Numeric, NilClass], default: nil
property :origin, [TrueClass, FalseClass, String], default: true

# Those defaults come from https://www.ripe.net/publications/docs/ripe-203
property :time_refresh, Numeric, default: 86400
property :time_retry, Numeric, default: 7200
property :time_expire, Numeric, default: 3600000
property :time_ttl, Numeric, default: 172800

property :records, Array

def initialize(resource_name, run_context)
  super
  node.default['named']['zone_files'] << resource_name
end

# load_current_value do
#   if ::File.exist?("#{node['named']['vardir']}/#{name}.db")
#     content IO.read("#{node['named']['vardir']}/#{name}.db")
#   end
# end

default_action :create
action :create do
  zone_path_no_serial = "#{node['named']['vardir']}/.chef/#{name}.db.erb"
  zone_path = "#{node['named']['vardir']}/#{name}.db"
  resource = self

  directory ("#{node['named']['vardir']}/.chef") do
    owner node['named']['user']
    group node['named']['group']
    mode 00750
  end

  template zone_path do
    source zone_path_no_serial
    local true
    variables serial: generate_zone_serial
    notifies :reload, "service[bind]"
    action :nothing
  end

  template zone_path_no_serial do
    source 'zone_file.erb'
    cookbook 'named'
    helpers Named::ZoneHelpers
    variables res: resource
    action :create
    notifies :create, "template[#{zone_path}]", :immediately
  end
end
