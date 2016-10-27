#
# Resource representing an acl in Bind9 options
#

property :name, String
property :match, Array, default: ['any']
property :options, Array, default: []

def initialize(resource_name, run_context)
  super
  node.default['named']['acls'] << resource_name
end

action :create do
end
