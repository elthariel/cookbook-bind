#
# Resource representing an Bind9 zone statement in named.conf
#

property :name, String, name_property: true
property :domain, String
property :type, String, default: 'master'
property :file, [NilClass, String], default: nil
property :view, [String, Array], default: []
property :allow_transfer, [Array], default: ['none']
property :allow_update, [Array], default: ['none']
property :options, Array, default: []
property :notify, [TrueClass, FalseClass], default: false

def initialize(resource_name, run_context)
  super
  node.default['named']['zones'] << resource_name
end

default_action :create
action :create do
end
