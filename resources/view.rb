#
# A resource representing a view statement in named.conf
#

property :name, String, name_property: true
property :clients, [NilClass, Array], default: nil
property :destinations, [NilClass, Array], default: nil
property :recursion, [TrueClass, FalseClass], default: false
property :options, Array, default: []

def initialize(resource_name, run_context)
  super
  node.default['named']['views'] << resource_name
end

action :create do
end
