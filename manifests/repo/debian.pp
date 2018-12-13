# Class: beegfs::repo::debian

class beegfs::repo::debian (
  $release,
  $manage_repo    = true,
  $package_source = $beegfs::package_source,
  Beegfs::Major_version $major_version  = $beegfs::major_version,
) {

  anchor { 'beegfs::apt_repo' : }

  include ::apt

  if $manage_repo {
    case $package_source {
      'beegfs': {
        apt::source { 'beegfs':
          location     => "http://www.beegfs.com/release/beegfs_${major_version}",
          repos        => 'non-free',
          architecture => 'amd64',
          release      => $release,
          key          => {
            'id'     => '055D000F1A9A092763B1F0DD14E8E08064497785',
            'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs',
          },
          include      => {
            'src' => false,
            'deb' => true,
          },
          before       => Anchor['beegfs::apt_repo'],
        }
      }
      default: {}
    }
    Class['apt::update'] -> Package<| tag == 'beegfs' |>
  }
}
