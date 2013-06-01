class utils::screen {
  package { 'screen':
    ensure => present
  }

  file { '/etc/screenrc':
    source => 'puppet:///modules/utils/etc/screenrc',
    mode   => '0644',
    owner  => root,
    group  => root,
  }
}
