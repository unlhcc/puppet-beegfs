# Class: beegfs::storage
#
# This module manages beegfs storage service
#
class beegfs::storage (
  $enable               = true,
  $storage_directory    = $beegfs::storage_directory,
  $allow_first_run_init = $beegfs::allow_first_run_init,
  $mgmtd_host           = $beegfs::mgmtd_host,
  $log_dir              = $beegfs::log_dir,
  $log_level            = 3,
  $user                 = $beegfs::user,
  $group                = $beegfs::group,
  $package_ensure       = $beegfs::package_ensure,
  $interfaces           = ['eth0'],
  $interfaces_file      = '/etc/beegfs/interfaces.storage',
  $mgmtd_tcp_port       = 8008,
  $mgmtd_udp_port       = 8008,
  $major_version        = $beegfs::major_version,
  $enable_quota         = $beegfs::enable_quota,
  $per_user_msg_queues  = false,
) inherits ::beegfs {

  require ::beegfs::install
  validate_array($interfaces)

  if $storage_directory.is_a(String) {
    $storage_directory.split(',').each |$d| {
      file { $d:
        ensure => directory,
        owner  => $user,
        group  => $group,
        before => Package['beegfs-storage'],
      }
    }
  } else {
    # with an array multiple directories are created
    file { $storage_directory:
      ensure => directory,
      owner  => $user,
      group  => $group,
      before => Package['beegfs-storage'],
    }
  }

  package { 'beegfs-storage':
    ensure => $package_ensure,
  }

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-storage.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${major_version}/beegfs-storage.conf.erb"),
    require => [
      File[$interfaces_file],
      Package['beegfs-storage'],
    ],
  }

  service { 'beegfs-storage':
    ensure     => lookup({
        'name'          => 'beegfs::storage::ensure',
        'default_value' => 'running'
    }),
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-storage'],
    subscribe  => [
      File['/etc/beegfs/beegfs-storage.conf'],
      File[$interfaces_file],
    ],
  }
}
