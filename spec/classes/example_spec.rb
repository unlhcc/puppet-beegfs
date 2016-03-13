require 'spec_helper'

describe 'beegfs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "beegfs class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('beegfs::params') }
          #it { is_expected.to contain_class('beegfs::install').that_comes_before('beegfs::config') }
#          #it { is_expected.to contain_class('beegfs::config') }
#          #it { is_expected.to contain_class('beegfs::service').that_subscribes_to('beegfs::config') }
#
          #it { is_expected.to contain_service('beegfs') }
          #it { is_expected.to contain_package('beegfs').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'beegfs class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('beegfs') }.to raise_error(Puppet::Error, /Nexenta is not supported/) }
    end
  end
end
