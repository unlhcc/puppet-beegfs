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
  $package_name = $::beegfs::params::package_name,
  $service_name = $::beegfs::params::service_name,
) inherits ::beegfs::params {

  # validate parameters here

  class { '::beegfs::install': } ->
  class { '::beegfs::config': } ~>
  class { '::beegfs::service': } ->
  Class['::beegfs']
}
