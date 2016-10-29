require 'chefspec'
require 'chefspec/berkshelf'

SPEC_PATH = File.expand_path(File.dirname(__FILE__))
ROOT_PATH = File.expand_path(File.join SPEC_PATH, '..')

# Require all our libraries
Dir["#{ROOT_PATH}/libraries/**/*.rb"].each { |f| require File.expand_path(f) }
# Require all our support files
Dir["#{SPEC_PATH}/support/**/*.rb"].each { |f| puts f; require File.expand_path(f) }

RSpec.configure do |config|
  config.cookbook_path = [
    File.join(ROOT_PATH, '..'),
    File.join(SPEC_PATH, 'fixtures', 'cookbooks')
  ]

  config.alias_example_to :they
end

at_exit { ChefSpec::Coverage.report! }
