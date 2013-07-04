# Make sure apt-get -y update runs before anything else.
stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}
class { 'apt_get_update':
  stage => preinstall
}

package { [ 'build-essential', 
'zlib1g-dev', 
'libssl-dev', 
'libreadline-dev', 
'git-core', 
'libxml2', 
'libxml2-dev', 
'libxslt1-dev',
'sqlite3',
'libsqlite3-dev']:
ensure => installed,
}

class install_mysql {
  class { 'mysql': }

  class { 'mysql::server':
    config_hash => { 'root_password' => '' }
  }

  package { 'libmysqlclient15-dev':
    ensure => installed
  }
}
class { 'install_mysql': }

class install-rvm {
  include rvm
  rvm::system_user { vagrant: ; }

  rvm_system_ruby {
    'ruby-1.9.3-p392':
      ensure => 'present',
      default_use => false;
  }

  rvm_gem {
    'ruby-1.9.3-p392/bundler': ensure => latest;
    'ruby-1.9.3-p392/rake': ensure => latest;
  }

}

class { 'install-rvm': }