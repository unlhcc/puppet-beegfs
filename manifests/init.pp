# Class: beegfs
# ===========================
#
# Full description of class beegfs here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class beegfs (
  $manage_repo                   = true,
  $mgmtd_host                    = 'localhost',
  $meta_directory                = '/meta',
  $storage_directory             = '/storage',
  $client_auto_remove_mins       = 0,
  $meta_space_low_limit          = '5G',
  $meta_space_emergency_limit    = '3G',
  $storage_space_low_limit       = '100G',
  $storage_space_emergency_limit = '10G',
  $package_source                = 'beegfs',
  $version                       = undef,
  $log_dir                       = '/var/log/beegfs',
  $user                          = 'root',
  $group                         = 'root',
  $major_version                 = '2015.03',
  $admon_db_file                 = '/var/lib/beegfs/beegfs-admon.db',
) inherits ::beegfs::params {

  # validate parameters here

  class { '::beegfs::install': } ->
  class { '::beegfs::config': } ~>
  class { '::beegfs::service': } ->
  Class['::beegfs']
}
