class percona::service {
  service { 'mysql':
    ensure    => running,
    enable    => true,
    require   => [
      Package['percona-server-server'],
    ],
  }
}
