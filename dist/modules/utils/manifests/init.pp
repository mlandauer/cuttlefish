class utils {

  class {'utils::curl':} ->
  class {'utils::vim':} ->
  class {'utils::screen':}
  class {'utils::network':} ->
  class {'utils::tmux':} ->
  class {'utils::facterpath':} ->

  package { [ 'less', 'logtail', 'tofrodos' ]:
    ensure => present
  } ->

  package { [ 'dbus', 'consolekit' ]:
    ensure => absent
  } ->

  group { 'admin':
    ensure => present,
  }
}
