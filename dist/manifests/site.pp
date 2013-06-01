Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

node default {
  class {'apt':
    always_apt_update => true
  }
  include utils

  include ruby::common
  ruby::version { '1.9.3-p125':
    is_default => true
  }

  class {'percona':}

  Class['apt'] ->
  Class['utils'] ->
  Class['ruby::common'] ->
  Class['percona']
}
