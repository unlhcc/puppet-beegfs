# Define: beegfs::mount
#
# This module manages beegfs mounts
#
define beegfs::mount (
  $client_cfg      = '/etc/beegfs/beegfs-client.conf',
  $mntops          = 'defaults',
  $user            = $beegfs::user,
  $group           = $beegfs::group,
  $major_version   = $beegfs::major_version,
  $mounts_cfg      = '/etc/beegfs/beegfs-mounts.conf',
  $interfaces_file = '/etc/beegfs/interfaces.client',
  $log_level       = 3,
  $mgmtd_host      = hiera('beegfs::mgmtd_host', $beegfs::mgmtd_host),
  $client_udp      = 8004,
  $helperd_tcp     = 8006,
  $mgmtd_tcp_port  = 8008,
  $mgmtd_udp_port  = 8008,
  $enable_quota    = $beegfs::enable_quota,
  $enable_acl      = $beegfs::enable_acl,
  $netfilter_file  = '/etc/beegfs/beegfs-netfilter.conf',
) {

  file { $name:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  concat::fragment { $name:
    target  => $mounts_cfg,
    content => "${name} ${client_cfg} beegfs ${mntops}",
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
