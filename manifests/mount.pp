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

  file_line { 'mnt_config':
    line    => "${mnt} ${cfg}",
    path    => $mounts_cfg,
    require => [ File[$mounts_cfg], File[$mnt] ],
  }
}
