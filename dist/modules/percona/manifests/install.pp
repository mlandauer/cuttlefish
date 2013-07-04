# percona::install
#
class percona::install {
  package { [
    'xtrabackup',
    'percona-toolkit',
    'percona-server-client',
    'percona-server-server'
  ]:
    ensure  => $percona::version,
  }
}
