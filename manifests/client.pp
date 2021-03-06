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
  Integer $helperd_tcp     = 8006,
          $major_version   = $beegfs::major_version,
          $kernel_packages = $beegfs::params::kernel_packages,
  Boolean $autobuild       = true,
          $autobuild_args  = '-j8',
          $netfilters      = [''],
          $netfilter_file  = '/etc/beegfs/beegfs-netfilter.conf',
          $mount_hook      = undef,
) inherits beegfs {

  require ::beegfs::install
  validate_array($interfaces)

  anchor { 'beegfs::kernel_dev' : }

  ensure_packages($kernel_packages, {
      'ensure' => $kernel_ensure,
      'before' => Anchor['beegfs::kernel_dev']
    }
  )

  file { '/etc/beegfs/beegfs-helperd.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${major_version}/beegfs-helperd.conf.erb"),
  }

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { $netfilter_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/beegfs-netfilter.erb'),
  }

  file { '/etc/beegfs/beegfs-client-autobuild.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${major_version}/beegfs-client-autobuild.conf.erb"),
  }

  file { '/etc/default/beegfs-client':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${major_version}/beegfs-client-sysconfig.erb"),
  }

  exec { '/etc/init.d/beegfs-client rebuild':
    path        => ['/usr/bin', '/usr/sbin'],
    subscribe   => File['/etc/beegfs/beegfs-client-autobuild.conf'],
    refreshonly => true,
    require     => Package['beegfs-client'],
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
    owner          => $user,
    group          => $group,
    mode           => '0644',
    require        => Package['beegfs-client'],
    ensure_newline => true,
  }

  service { 'beegfs-client':
    ensure     => running,
    restart    => '/bin/true', # singularity jobs prevent clean restarts
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Package['beegfs-client'],
      Service['beegfs-helperd'],
      File[$interfaces_file],
    ],
    subscribe  => [
      Concat['/etc/beegfs/beegfs-mounts.conf'],
      File['/etc/beegfs/beegfs-helperd.conf'],
      Exec['/etc/init.d/beegfs-client rebuild'],
      File[$interfaces_file],
      File[$netfilter_file],
    ],
  }
}
