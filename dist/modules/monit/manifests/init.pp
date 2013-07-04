class monit {
  package { 'monit':
    ensure => present
  }

  augeas { '/etc/default/monit enable_at_boot':
    context => '/files/etc/default/monit',
    changes => 'set startup 1',
    require => [
      Package['monit']
    ],
  }

  file { '/etc/monit/monitrc':
    content => template("monit/etc/monit/monitrc.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => [
      Package['monit'],
    ],
    notify  => [
      Service['monit'],
    ],
  }

  service { 'monit':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => [
      Augeas['/etc/default/monit enable_at_boot'],
      File['/etc/monit/monitrc'],
    ],
  }

  file { '/etc/monit/conf.d/monitor':
    content => "set httpd port 2812 address localhost\n  allow localhost",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => [
      Package['monit'],
    ],
    notify  => [
      Service['monit'],
    ],
  }

}
