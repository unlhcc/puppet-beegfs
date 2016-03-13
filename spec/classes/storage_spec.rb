require 'spec_helper'

describe 'beegfs::storage' do
  let(:hiera_data) { { 'beegfs::mgmtd_host' => "foo.bar" } }

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :lsbdistid => 'Debian',
  }}

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  let(:params) {{
    'user'  => user,
    'group' => group,
    :major_version => '2015.03',
  }}

  it { is_expected.to contain_class('beegfs::storage') }

  shared_examples 'debian-storage' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :lsbdistid => 'Debian',
    }}

    it { should contain_package('beegfs-utils') }
    it { should contain_service('beegfs-storage').with(
        :ensure => 'running',
        :enable => true
    ) }

    it { should contain_file('/etc/beegfs/beegfs-storage.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    }) }

    it { should contain_file('/srv/beefgs/storage').with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { is_expected.to contain_service('beegfs-storage').with(
        :ensure => 'running',
        :enable => true
    ) }
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    let(:params) {{
      'user'  => user,
      'group' => group,
      :major_version => '2015.03',
      :storage_directory => '/srv/beefgs/storage'
    }}

    it_behaves_like 'debian-storage', 'Debian', 'wheezy'
    it_behaves_like 'debian-storage', 'Ubuntu', 'precise'
  end

  context 'with given version' do
    let(:version) { '2012.10.r8.debian7' }
    let(:params) {{
      :package_ensure => version,
      :major_version  => '2015.03',
    }}

    it { should contain_package('beegfs-storage').with({
      'ensure' => version
    }) }
  end

  it { should contain_file('/etc/beegfs/interfaces.storage').with({
    'ensure'  => 'present',
    'owner'   => user,
    'group'   => group,
    'mode'    => '0755',
  }).with_content(/eth0/) }

  context 'interfaces file' do
    let(:params) {{
      :interfaces      => ['eth0', 'ib0'],
      :interfaces_file => '/etc/beegfs/store.itf',
      :user            => user,
      :group           => group,
      :major_version   => '2015.03',
    }}

    it { should contain_file('/etc/beegfs/store.itf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    }).with_content(/ib0/) }


    it { should contain_file(
        '/etc/beegfs/beegfs-storage.conf'
      ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/store.itf/)
    }
  end

  it { should contain_file(
    '/etc/beegfs/beegfs-storage.conf'
  ).with_content(/logLevel(\s+)=(\s+)3/) }

  context 'changing log level' do
    let(:params) {{
      :log_level => 5,
      :major_version => '2015.03',
    }}

    it { should contain_file(
      '/etc/beegfs/beegfs-storage.conf'
    ).with_content(/logLevel(\s+)=(\s+)5/) }
  end

  context 'set mgmtd host' do
    let(:params) {{
      :mgmtd_host => 'mgmtd.beegfs.com',
      :major_version => '2015.03',
    }}

    it { should contain_file(
      '/etc/beegfs/beegfs-storage.conf'
    ).with_content(/sysMgmtdHost(\s+)=(\s+)mgmtd.beegfs.com/) }
  end

  context 'set mgmtd tcp port' do
    let(:params) {{
      :mgmtd_tcp_port => 9009,
      :major_version  => '2015.03',
    }}

    it { should contain_file(
      '/etc/beegfs/beegfs-storage.conf'
    ).with_content(/connMgmtdPortTCP(\s+)=(\s+)9009/) }
  end

end
