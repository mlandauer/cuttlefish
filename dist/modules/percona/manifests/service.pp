# percona::service
# manages whether percona-server is enabled at boot and running or not
#
class percona::service {
  $ensure = $percona::start ? { true => running, default => stopped }

  service { 'mysql':
    ensure  => $ensure,
    enable  => $percona::enable
  }
}
