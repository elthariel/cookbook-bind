require 'spec_helper'

describe 'named::default' do
  context 'on Ubuntu 16.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04',
                                 step_into: ['named_zone_file'])
        .converge(described_recipe)
    end

    let(:checkconf) { chef_run.execute('named-checkconf') }

    %w(bind9 bind9utils).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'creates /var/cache/bin with mode 750 and owner named' do
      expect(chef_run).to create_directory('/var/cache/bind').with(
        mode: 00750,
        user: 'bind'
      )
    end

    it 'creates /etc/bind with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/etc/bind').with(
        mode: 00750,
        user: 'bind'
      )
    end

    it 'renders file /etc/bind/named.options' do
      expect(chef_run).to render_file('/etc/bind/named.options')
    end

    it 'renders file /etc/bind/named.conf with included files' do
      expect(chef_run).to render_file('/etc/bind/named.conf').with_content(%r{include "/etc/bind/named.options"})
    end

    %w(named.empty named.loopback named.localhost named.ca).each do |var_file|
      it "it creates cookbook file /var/cache/bind/#{var_file}" do
        expect(chef_run).to create_cookbook_file("/var/cache/bind/#{var_file}")
      end
    end

    it 'executes rndc-confgen -a' do
      expect(chef_run).to run_execute('rndc-confgen -a')
    end

    # %w(data slaves master).each do |subdir|
    #   it "creates subdirectory /var/named/#{subdir}" do
    #     expect(chef_run).to create_directory("/var/named/#{subdir}")
    #   end
    # end

    it 'named-checkconf notifies bind service' do
      expect(checkconf).to notify('service[bind]').to(:start).immediately
      expect(checkconf).to notify('service[bind]').to(:enable).immediately
    end
  end
end
