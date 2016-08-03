require 'spec_helper'

describe 'beegfs::meta' do
  let(:facts) do
    {
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :lsbdistid => 'Debian',
  }
  end

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  let(:params) do
    {
    :user  => user,
    :group => group,
    :major_version => '2015.03',
  }
  end

  it { is_expected.to contain_class('beegfs::meta') }
  it { is_expected.to contain_class('beegfs::install') }

  shared_examples 'debian-meta' do |os, codename|
    let(:facts) do
      {
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :lsbdistid => 'Debian',
    }
    end
    it { should contain_package('beegfs-meta') }
    it { should contain_package('beegfs-utils') }

    it { should contain_class('beegfs::repo::debian') }

    it do
      should contain_service('beegfs-meta').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      should contain_file('/etc/beegfs/beegfs-meta.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    })
    end
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    it_behaves_like 'debian-meta', 'Debian', 'wheezy'
    it_behaves_like 'debian-meta', 'Ubuntu', 'precise'
  end

  context 'allow changing parameters' do
    let(:params) do
      {
      :mgmtd_host => '192.168.1.1',
      :major_version => '2015.03',
    }
    end

    it do
      should contain_file(
        '/etc/beegfs/beegfs-meta.conf'
      ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
    end
  end

  context 'with given version' do
    let(:facts) do
      {
      :operatingsystem => 'Debian',
      :osfamily => 'Debian',
      :lsbdistcodename => 'wheezy',
      :lsbdistid => 'Debian',
    }
    end
    let(:version) { '2015.03.r8.debian7' }
    let(:params) do
      {
      :package_ensure => version,
      :major_version => '2015.03',
    }
    end

    it do
      should contain_package('beegfs-meta').with({
      'ensure' => version
    })
    end
  end

  it do
    should contain_file('/etc/beegfs/interfaces.meta').with({
    'ensure'  => 'present',
    'owner'   => user,
    'group'   => group,
    'mode'    => '0755',
  }).with_content(/eth0/)
  end

  context 'interfaces file' do
    let(:params) do
      {
      :interfaces      => ['eth0', 'ib0'],
      :interfaces_file => '/etc/beegfs/meta.itf',
      :user            => user,
      :group           => group,
      :major_version   => '2015.03',
    }
    end

    it do
      should contain_file('/etc/beegfs/meta.itf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0755',
    }).with_content(/ib0/)
    end


    it do
      should contain_file(
        '/etc/beegfs/beegfs-meta.conf'
      ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/meta.itf/)
    end
  end

  it do
    should contain_file(
      '/etc/beegfs/beegfs-meta.conf'
    ).with_content(/logLevel(\s+)=(\s+)3/)
  end

  context 'changing log level' do
    let(:params) do
      {
      :log_level => 5,
      :major_version => '2015.03',
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-meta.conf'
      ).with_content(/logLevel(\s+)=(\s+)5/)
    end
  end

  context 'hiera should override defaults' do
    let(:params) do
      {
      :mgmtd_host => '192.168.1.1',
      :major_version => '2015.03',
    }
    end

    it do
      should contain_file(
        '/etc/beegfs/beegfs-meta.conf'
      ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
    end
  end
end
