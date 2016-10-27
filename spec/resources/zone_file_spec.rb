require 'spec_helper'

describe 'named_zone_file' do
  let :chef_run do
    ChefSpec::SoloRunner.new(step_into: ['named_zone_file'],
                             platform: 'ubuntu',
                             version: '16.04').converge('example::simple_zone')
  end

  let(:tpl_path) { '/var/cache/bind/.chef/test.fr.db.erb' }
  let(:zone_path) { '/var/cache/bind/test.fr.db' }

  let (:test_fr_db){ fixture_file 'test.fr.db' }


  it 'Create a .chef folder in vardir' do
    expect(chef_run).to create_directory("/var/cache/bind/.chef")
  end

  it 'Generate a proper template zone file' do
    expect(chef_run).to render_file(tpl_path).with_content(test_fr_db)
  end

  it 'Creates the real zone file' do
    expect(chef_run.template(zone_path)).to do_nothing
    expect(chef_run.template(tpl_path))
      .to notify("template[#{zone_path}]").to(:create).immediately
  end

  it 'Add the defined zones to an attribute' do
    expect(chef_run.node['named']['zone_files']).to eq(['test.fr'])
  end

  it 'Triggers a reload of service[bind]' do
    expect(chef_run.template(zone_path))
      .to notify("service[bind]").to(:reload)
  end

  # it 'Include the zone in named.conf' do
  #   expect(chef_run).to render_file('/etc/bind/named.conf')
  #                        .with_content('zone "test.fr"')
  #                        .with_content("type master;")
  #                        .with_content("file #{zone_path};")
  # end
end
