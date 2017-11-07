# Class: beegfs
# ===========================
#
#
# Parameters
# ----------
#
# * `mgmtd_host`
#   ipaddress of management node
#
class beegfs (
  $quota_enable_enforcement      = true,
  $manage_repo                   = true,
  $mgmtd_host                    = 'localhost',
  $meta_directory                = '/srv/beegfs/meta',
  $storage_directory             = '/srv/beegfs/storage',
  $client_auto_remove_mins       = 30,
  $meta_space_low_limit          = '10G',
  $meta_space_emergency_limit    = '3G',
  $storage_space_low_limit       = '100G',
  $storage_space_emergency_limit = '20G',
  $package_source                = 'beegfs',
  $version                       = undef,
  $log_dir                       = '/var/log/beegfs',
  $user                          = 'root',
  $group                         = 'root',
  $major_version                 = '2015.03',
  $admon_db_file                 = '/var/lib/beegfs/beegfs-admon.db',
) inherits ::beegfs::params {

  if ($version == undef){
    $package_ensure = 'present'
  }else{
    $package_ensure = $version
  }
}
