require 'spec_helper'

describe 'beegfs::client' do

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :lsbdistid => 'Debian',
  }}

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  let(:params) {{
    :user  => user,
    :group => group,
  }}

  it { is_expected.to contain_class('beegfs::client') }

  shared_examples 'debian_beegfs-client' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :lsbdistid => 'Debian',
    }}
    it { is_expected.to contain_package('beegfs-client') }
    it { is_expected.to contain_package('linux-headers-amd64') }
    it { is_expected.to contain_package('beegfs-helperd') }
    it { is_expected.to contain_package('beegfs-client') }

    it { is_expected.to contain_service('beegfs-client').with(
        :ensure => 'running',
        :enable => true
    ) }

    it { is_expected.to contain_service('beegfs-helperd').with(
        :ensure => 'running',
        :enable => true
    ) }

    it { is_expected.to contain_concat('/etc/beegfs/beegfs-mounts.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644'
    }) }

    it { is_expected.to contain_file('/etc/beegfs/beegfs-client.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    }) }

  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    it_behaves_like 'debian_beegfs-client', 'Debian', 'squeeze'
    it_behaves_like 'debian_beegfs-client', 'Debian', 'wheezy'
    it_behaves_like 'debian_beegfs-client', 'Ubuntu', 'precise'
  end

  context 'on RedHat' do
    let(:facts) {{
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
      :lsbdistcodename => '6',
      :lsbdistid => 'RedHat',
    }}
    let(:params){{
      :kernel_ensure => '12.036+nmu3'
    }}

    # kernel packages have different versions than beegfs
    it { is_expected.to contain_package('kernel-devel').with({
      'ensure' => '12.036+nmu3'
    }) }
  end

  context 'with given version' do
    let(:version) { '2012.10.r8.debian7' }
    let(:params) {{
      :package_ensure => version
    }}

    it { is_expected.to contain_package('beegfs-client').with({
      'ensure' => version
    }) }
    it { should contain_package('linux-headers-amd64').with({
      'ensure' => 'present'
    }) }
    it { should contain_package('beegfs-helperd').with({
      'ensure' => version
    }) }
    it { should contain_package('beegfs-client').with({
      'ensure' => version
    }) }
  end

  it { should contain_file('/etc/beegfs/interfaces.client').with({
    'ensure'  => 'present',
    'owner'   => user,
    'group'   => group,
    'mode'    => '0755',
  }).with_content(/eth0/) }

  context 'interfaces file' do
    let(:params) {{
      :interfaces      => ['eth0', 'ib0'],
      :interfaces_file => '/etc/beegfs/client.itf',
      :user            => user,
      :group           => group,
    }}

    it { should contain_file('/etc/beegfs/client.itf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    }).with_content(/ib0/) }


    it { should contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/client.itf/)
    }
  end

  it { should contain_file(
    '/etc/beegfs/beegfs-client.conf'
  ).with_content(/logLevel(\s+)=(\s+)3/) }

  context 'changing log level' do
    let(:params) {{
      :log_level => 5,
    }}

    it { should contain_file(
      '/etc/beegfs/beegfs-client.conf'
    ).with_content(/logLevel(\s+)=(\s+)5/) }
  end

  context 'allow changing mgmtd_host' do
    let(:params) {{
      :mgmtd_host => '192.168.1.1',
    }}

    it {
      should contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
    }
  end

end
