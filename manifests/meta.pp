# Class: beegfs::meta
#
# This module manages beegfs meta service
#
class beegfs::meta (
  $enable               = true,
  $meta_directory       = $beegfs::meta_directory,
  $allow_first_run_init = $beegfs::allow_first_run_init,
  $mgmtd_host           = $beegfs::mgmtd_host,
  $log_dir              = $beegfs::log_dir,
  $log_level            = 3,
  $user                 = $beegfs::user,
  $group                = $beegfs::group,
  $package_ensure       = hiera('beegfs::package_ensure', $beegfs::package_ensure),
  $interfaces           = ['eth0'],
  $interfaces_file      = '/etc/beegfs/interfaces.meta',
  $major_version        = $beegfs::major_version,
  $enable_acl           = $beegfs::enable_acl,
) inherits ::beegfs {

  require ::beegfs::install
  validate_array($interfaces)

  package { 'beegfs-meta':
    ensure => $package_ensure,
  }

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-meta.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${major_version}/beegfs-meta.conf.erb"),
    require => [
      File[$interfaces_file],
      Package['beegfs-meta'],
    ],
  }

  service { 'beegfs-meta':
    ensure     => lookup({
        'name'          => 'beegfs::meta::ensure',
        'default_value' => 'running'
    }),
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-meta'],
    subscribe  => [
      File['/etc/beegfs/beegfs-meta.conf'],
      File[$interfaces_file]
    ],
  }
}
