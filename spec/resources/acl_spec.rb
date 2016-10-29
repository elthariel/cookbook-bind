require 'spec_helper'

describe 'named_acl' do
  let :chef_run do
    ChefSpec::SoloRunner.new(step_into: ['named_acl'],
                             platform: 'ubuntu',
                             version: '16.04').converge('example::simple_acl')
  end

  describe 'properties' do
    they 'exist' do
      expect(chef_run).to create_acl('my_acl')
                           .with(match: ['localnets', '10.0.0.0/24'])
                           .with(options: ['opt1;'])

    end

    they 'have default values' do
      expect(chef_run).to create_acl('default_acl')
                           .with(name: 'default_acl')
                           .with(match: ['any'])
                           .with(options: [])
    end
  end

  it 'populates an attribute with acl names' do
    expect(chef_run.node['named']['acls']).to eq(['my_acl', 'default_acl'])
  end

  it 'adds an acl entry to named.options' do
    expect(chef_run).to render_file('/etc/bind/named.options')
                         .with_content('acl "my_acl"')
                         .with_content('10.0.0.0/24;')
  end
end
