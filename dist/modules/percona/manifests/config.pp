class percona::config {
  file { '/etc/logrotate.d/percona-server-server-5.5':
    source => 'puppet:///modules/percona/etc/logrotate.d/percona-server',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}

class percona::service {
  service { 'mysql':
    ensure    => running,
    enable    => true,
    require   => [
      Package['percona-server-server'],
    ],
  }
}
