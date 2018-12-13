# Class: beegfs::meta
#
# This module manages beegfs meta service
#
class beegfs::meta (
  Boolean               $enable               = true,
  Stdlib::AbsolutePath  $meta_directory       = $beegfs::meta_directory,
  Boolean               $allow_first_run_init = true,
  Stdlib::Host          $mgmtd_host           = $beegfs::mgmtd_host,
  Stdlib::AbsolutePath  $log_dir              = $beegfs::log_dir,
  Beegfs::LogLevel      $log_level            = 3,
  String                $user                 = $beegfs::user,
  String                $group                = $beegfs::group,
                        $package_ensure       = hiera('beegfs::package_ensure', $beegfs::package_ensure),
  Array[String]         $interfaces           = ['eth0'],
  Stdlib::AbsolutePath  $interfaces_file      = '/etc/beegfs/interfaces.meta',
  Beegfs::Major_version $major_version        = $beegfs::major_version,
  Boolean               $enable_acl           = $beegfs::enable_acl,
) inherits ::beegfs {

  require ::beegfs::install

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
    ensure     => running,
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
