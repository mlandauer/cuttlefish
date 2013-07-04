# percona::apt
# insure the percona apt repo is installed
#
class percona::apt {
  apt::source { 'percona':
    location    => 'http://repo.percona.com/apt',
    repos       => 'main',
    key         => 'CD2EFD2A',
    include_src => false,
  }
}
