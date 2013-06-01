class percona::install(
  $innodb_file_per_table = true
) {
  apt::source { 'percona':
    location    => 'http://repo.percona.com/apt',
    repos       => 'main',
    key         => 'CD2EFD2A',
    include_src => false,
  }

  package { [
    'xtrabackup',
    'percona-toolkit',
  ]:
    ensure  => present,
    require => [
      Apt::Source['percona'],
    ]
  }

  package { 'percona-server-client':
    ensure  => present,
    require => [
      Apt::Source['percona'],
    ]
  }

  file { '/etc/mysql':
    ensure => directory
  }

  file { '/etc/mysql/my.cnf':
    ensure  => present,
    content => template('percona/my.cnf.erb'),
    owner   => root,
    group   => admin,
    mode    => '0664',
    require => [
      Apt::Source['percona'],
      File['/etc/mysql']
    ],
    before  => [
      Package['percona-server-server'],
    ]
  }

  package { 'percona-server-server':
    ensure  => present,
    require => [
      Package['percona-server-client'],
    ]
  }
}

