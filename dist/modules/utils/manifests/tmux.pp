class utils::tmux {
  package { 'tmux':
    ensure => present
  }

  file { '/etc/tmux.conf':
    source => 'puppet:///modules/utils/etc/tmux.conf',
    mode   => '0644',
    owner  => root,
    group  => root,
  }
}
