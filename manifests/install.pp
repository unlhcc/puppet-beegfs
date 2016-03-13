# == Class beegfs::install
#
# This class is called from beegfs for install.
#
class beegfs::install {

  package { $::beegfs::package_name:
    ensure => present,
  }
}
