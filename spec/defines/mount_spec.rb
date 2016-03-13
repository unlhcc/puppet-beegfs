require 'spec_helper'

describe 'beegfs::mount' do

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :lsbdistid => 'Debian',
  }}

  let(:title) { '/mnt/share' }

  let(:params) {{
    :cfg   => '/etc/beegfs/beegfs-clients.conf',
    :mnt   => '/mnt/share',
  }}

  it { should contain_concat__fragment(
    '/mnt/share'
    ).with_content('/mnt/share /etc/beegfs/beegfs-clients.conf')
  }

end
