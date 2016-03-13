# Class: beegfs::client
#
# This module manages beegfs client
#
class beegfs::client (
  $user            = $beegfs::user,
  $group           = $beegfs::group,
  $package_ensure  = $beegfs::package_ensure,
  $kernel_ensure   = present,
  $interfaces      = ['eth0'],
  $interfaces_file = '/etc/beegfs/interfaces.client',
  $log_level       = 3,
  $mgmtd_host      = hiera('beegfs::mgmtd_host', $beegfs::mgmtd_host),
  $mgmtd_tcp_port  = 8008,
  $mgmtd_udp_port  = 8008,
  $major_version   = $beegfs::major_version,
  $kernel_packages = $beegfs::params::kernel_packages,
) inherits beegfs {

  require beegfs::install
  validate_array($interfaces)

  anchor { 'beegfs::kernel_dev' : }

  ensure_packages($kernel_packages, {
      'ensure' => $kernel_ensure,
      'before' => Anchor['beegfs::kernel_dev']
    }
  )

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-client.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => [
      Package['beegfs-utils'],
      File[$interfaces_file],
    ],
    content => template("beegfs/${major_version}/beegfs-client.conf.erb"),
  }

  package { 'beegfs-helperd':
    ensure => $package_ensure,
  }

  package { 'beegfs-client':
    ensure  => $package_ensure,
    require => Anchor['beegfs::kernel_dev'],
  }

  service { 'beegfs-helperd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-helperd'],
  }

  concat { '/etc/beegfs/beegfs-mounts.conf':
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Package['beegfs-client'],
  }

  service { 'beegfs-client':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['beegfs-client'],
      Service['beegfs-helperd'],
      File[$interfaces_file],
    ],
    subscribe  => [
      Concat['/etc/beegfs/beegfs-mounts.conf'],
      File[$interfaces_file],
    ],
  }
}
