# Define: beegfs::mount
#
# This module manages beegfs mounts
#
define beegfs::mount (
  $cfg,
  $mnt,
  $user       = $beegfs::user,
  $group      = $beegfs::group,
  $mounts_cfg = '/etc/beegfs/beegfs-mounts.conf',
) {

  include beegfs::client

  file { $mnt:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  concat::fragment { $mnt:
    ensure  => present,
    target  => $mounts_cfg,
    content => "${mnt} ${cfg}",
    require => [ Concat[$mounts_cfg], File[$mnt] ],
  }

}
