# == Class beegfs::params
#
# This class is meant to be called from beegfs.
# It sets variables according to platform.
#
class beegfs::params {

  case $::operatingsystem {
    Debian: {
      case $::lsbdistcodename {
        'wheezy': {
          $release = 'deb7'
        }
        'squeeze': {
          $release = 'deb6'
        }
        'jessie': {
          $release = 'deb8'
        }
        default: {
          $release = 'deb8'
        }
      }
    }
    Ubuntu: {
      case $::lsbdistcodename {
        'precise': {
          $release = 'deb7'
        }
        default: {
          $release = 'deb7'
        }
      }
    }
    default: {
      fail("Family: ${::osfamily} OS: ${::operatingsystem} is not supported yet") #"
    }
  }
}
