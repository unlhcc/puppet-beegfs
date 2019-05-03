# Define: beegfs::mount
#
# This module manages beegfs mounts
#
define beegfs::mount (
          $client_cfg      = '/etc/beegfs/beegfs-client.conf',
  String  $mntops          = 'defaults',
          $user            = $beegfs::user,
          $group           = $beegfs::group,
          $major_version   = $beegfs::major_version,
          $mounts_cfg      = '/etc/beegfs/beegfs-mounts.conf',
          $interfaces_file = '/etc/beegfs/interfaces.client',
  Integer $log_level       = 3,
          $mgmtd_host      = hiera('beegfs::mgmtd_host', $beegfs::mgmtd_host),
  Integer $client_udp      = 8004,
  Integer $helperd_tcp     = 8006,
          $helperd_ip      = '',
  Integer $mgmtd_tcp_port  = 8008,
  Integer $mgmtd_udp_port  = 8008,
  Boolean $enable_quota    = $beegfs::enable_quota,
  Boolean $enable_acl      = $beegfs::enable_acl,
  Boolean $tune_refresh_on_get_attr = false,
          $netfilter_file  = '/etc/beegfs/beegfs-netfilter.conf',
  String  $vfstype         = 'beegfs',
) {

  file { $name:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  concat::fragment { $name:
    target  => $mounts_cfg,
    content => "${name} ${client_cfg} ${vfstype} ${mntops}",
    require => File[$name],
  }

  file { $client_cfg:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require =>[
      Package['beegfs-utils'],
      File[$interfaces_file]
    ],
    content => template("beegfs/${major_version}/beegfs-client.conf.erb"),
    notify  => Service['beegfs-client'],
  }

}
