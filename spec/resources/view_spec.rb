require 'spec_helper'

describe 'named_view' do
  let :chef_run do
    ChefSpec::SoloRunner.new(step_into: ['named_acl', 'named_view', 'named_zone'],
                             platform: 'ubuntu',
                             version: '16.04').converge('example::split_horizon')
  end
  let (:split_horizon){ fixture_file 'split_horizon.conf' }

  it 'exists' do
    expect(chef_run).to create_view('internal-view').with(recursion: true)
    expect(chef_run).to create_view('external-view')
    expect(chef_run).to create_acl('internal')
    expect(chef_run).to create_acl('external')
    expect(chef_run).to create_zone('internal').with(view: 'internal-view')
    expect(chef_run).to create_zone('external').with(view: 'external-view')
  end

  it 'populates an attribute with the views' do
    expect(chef_run.node['named']['views'])
      .to eq(['internal-view', 'external-view'])
  end

  it 'adds a view entry to named.conf' do
    expect(chef_run).to render_file('/etc/bind/named.conf')
                         .with_content(split_horizon)
  end

end
