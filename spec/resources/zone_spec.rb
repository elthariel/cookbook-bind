require 'spec_helper'

describe 'named_zone' do
  let :chef_run do
    ChefSpec::SoloRunner.new(step_into: ['named_zone'],
                             platform: 'ubuntu',
                             version: '16.04')
      .converge('example::simple_zone')
  end

  describe 'properties' do
    they 'have default values' do
      expect(chef_run).to create_zone('default_zone')
                           .with(name: 'default_zone')
                           .with(domain: 'test.fr')
                           .with(type: 'master')
                           .with(file: nil)
                           .with(view: [])
                           .with(allow_transfer: ['none'])
                           .with(allow_update: ['none'])
                           .with(options: [])
                           .with(notify: false)
    end
  end
end
