# == Class beegfs::service
#
# This class is meant to be called from beegfs.
# It ensure the service is running.
#
class beegfs::service {

  service { $::beegfs::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
