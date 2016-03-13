# Class: beegfs::repo
#
# This module manages beegfs repository installation
#
#
# This class file is not called directly
class beegfs::repo(
  $manage_repo    = $beegfs::manage_repo,
  $package_source = $beegfs::package_source,
  $release,
) inherits beegfs {
  anchor { 'beegfs::repo::begin': }
  anchor { 'beegfs::repo::end': }

  case $::osfamily {
    Debian: {
      class { 'beegfs::repo::debian':
        package_ensure => $package_ensure,
        release        => $release,
        require        => Anchor['beegfs::repo::begin'],
        before         => Anchor['beegfs::repo::end'],
      }
    }
    RedHat: {
      class { 'beegfs::repo::redhat':
        package_ensure => $package_ensure,
        require        => Anchor['beegfs::repo::begin'],
        before         => Anchor['beegfs::repo::end'],
      }
    }
    default: {
      fail("Module '${module_name}' is not supported on OS: '${::operatingsystem}', family: '${::osfamily}'")
    }
  }
}
