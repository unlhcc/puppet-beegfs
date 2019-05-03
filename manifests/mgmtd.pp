# Class: beegfs::mgmtd
#
# This module manages BeeGFS mgmtd
#
class beegfs::mgmtd (
          $enable                        = true,
          $directory                     = '/srv/beegfs/mgmtd',
  Boolean $allow_first_run_init          = $beegfs::allow_first_run_init,
          $client_auto_remove_mins       = $beegfs::client_auto_remove_mins,
          $meta_space_low_limit          = $beegfs::meta_space_low_limit,
          $meta_space_emergency_limit    = $beegfs::meta_space_emergency_limit,
          $storage_space_low_limit       = $beegfs::storage_space_low_limit,
          $storage_space_emergency_limit = $beegfs::storage_space_emergency_limit,
          $version                       = $beegfs::version,
          $log_dir                       = $beegfs::log_dir,
  Integer $log_level                     = 2,
          $user                          = $beegfs::user,
          $group                         = $beegfs::group,
          $package_ensure                = $beegfs::package_ensure,
          $interfaces                    = ['eth0'],
          $interfaces_file               = '/etc/beegfs/interfaces.mgmtd',
          $major_version                 = $beegfs::major_version,
  Boolean $enable_quota                  = $beegfs::enable_quota,
  Boolean $allow_new_servers             = $beegfs::allow_new_servers,
  Boolean $allow_new_targets             = $beegfs::allow_new_targets,
  ) inherits ::beegfs {
  require ::beegfs
  require ::beegfs::install
  validate_array($interfaces)

  package { 'beegfs-mgmtd':
    ensure => $package_ensure,
  }

  # mgmgtd main directory
  file { $directory:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-mgmtd.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template("beegfs/${major_version}/beegfs-mgmtd.conf.erb"),
    require => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
    ],
  }

  service { 'beegfs-mgmtd':
    ensure     => lookup({
        'name'          => 'beegfs::mgmtd::ensure',
        'default_value' => 'running'
    }),
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
    ],
    subscribe  => [
      File['/etc/beegfs/beegfs-mgmtd.conf'],
      File[$interfaces_file],
    ],
  }
}
