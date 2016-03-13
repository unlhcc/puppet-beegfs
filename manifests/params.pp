# == Class beegfs::params
#
# This class is meant to be called from beegfs.
# It sets variables according to platform.
#
class beegfs::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'beegfs'
      $service_name = 'beegfs'
    }
    'RedHat', 'Amazon': {
      $package_name = 'beegfs'
      $service_name = 'beegfs'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
