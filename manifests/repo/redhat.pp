# Class: beegfs::repo::redhat

class beegfs::repo::redhat (
  Boolean               $manage_repo    = true,
  Enum['beegfs']        $package_source = $beegfs::package_source,
                        $package_ensure = $beegfs::package_ensure,
  Beegfs::Major_version $major_version  = $beegfs::major_version,
) {

  $_os_release = $facts.dig('os', 'release', 'major')

  # If using the old version pattern the release folder is the same as the major
  # version; if using the new pattern we need to replace dots (`.`) with spaces
  # (` `)
  $_beegfs_release = if $major_version =~ /^\d{4}/ {
    $major_version
  } else {
    $major_version.regsubst('\.', '_')
  }

  if $manage_repo {
    case $package_source {
      'beegfs': {
        yumrepo { "beegfs_rhel${_os_release}":
          ensure    => 'present',
          descr     => "BeeGFS ${major_version} (rhel${_os_release})",
          baseurl   => "https://www.beegfs.io/release/beegfs_${_beegfs_release}/dists/rhel${_os_release}",
          gpgkey    => "https://www.beegfs.io/release/beegfs_${_beegfs_release}/gpg/RPM-GPG-KEY-beegfs",
          enabled   => '1',
          gpgcheck  => '1',
        }
      }
    }
  }
}
