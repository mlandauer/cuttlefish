class utils {

  include utils::curl
  include utils::vim
  include utils::screen
  include utils::nmap
  include utils::network
  include utils::tmux
  include utils::facterpath

  package { [ 'less', 'logtail', 'tofrodos' ]:
    ensure => present
  }

  package { [ 'dbus', 'consolekit' ]:
    ensure => absent
  }

  group { 'admin':
    ensure => present,
    tag    => 'puppet',
  }
}
