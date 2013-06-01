class ruby::common {
  include git::common
  include utils

  case $lsbdistcodename {
    lucid: {
      package { [
        'ruby',
        'rdoc',
        'rdoc1.8',
        'irb',
        'irb1.8',
        'libreadline-ruby',
        'libreadline-ruby1.8',
      ]:
        ensure => present,
        tag   => 'puppet'
      }
    }
    precise: {
      package { [
        'ruby',
      ]:
        ensure => present,
        tag   => 'puppet'
      }
    }
    default: {
      notify("Class ruby::common is not supported on $lsbdistcodename")
    }
  }


  exec { 'download-ruby-build':
    command => '/usr/bin/git clone git://github.com/sstephenson/ruby-build.git /opt/ruby-build',
    creates => '/opt/ruby-build',
    require => Package['git'],
  }

  exec { 'install-ruby-build':
    command => '/opt/ruby-build/install.sh',
    cwd     => '/opt/ruby-build',
    creates => '/usr/local/bin/ruby-build',
    require => [ Exec['download-ruby-build'],
                 Package['zlib1g-dev'], ],
  }

  # Common packages needed by ruby gems
  package { [
    'libmysqlclient-dev',
    'libssl-dev',
    'libreadline-dev',
    'libxslt1-dev',
    'libxml2-dev',
    'build-essential',
    'libcurl4-openssl-dev',
    'zlib1g-dev',
    'libsqlite3-dev',
    'sqlite3',
    ]:
    ensure => installed,
    before => [
      Exec['install-ruby-build'],
    ],
  }

  case $operatingsystem {
    RedHat: {
      package { 'ruby-devel':
        ensure => present,
      }
    }
    ubuntu: {
      package { 'ruby-dev':
        ensure => present,
      }
    }
    default: {
      fail("Module $module_name is not supported on $operatingsystem")
    }
  }

  # This is a wrapper of the gem command, used by the rbenvgem package provider.
  file { '/usr/local/bin/rbenv-gem':
    source  => 'puppet:///modules/ruby/rbenv-gem',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    tag     => 'puppet',
  }

  # This sets up an rbenv environment to run a command (for, say, sudoing something)
  file { '/usr/local/bin/rbenv-exec':
    source  => 'puppet:///modules/ruby/rbenv-exec',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    tag     => 'puppet',
  }

  exec { 'rbenv-download':
    command => '/usr/bin/git clone git://github.com/sstephenson/rbenv /opt/rbenv',
    creates => '/opt/rbenv',
    require => [
      Package['git'],
      Exec['install-ruby-build'],
      File['/usr/local/bin/rbenv-gem'],
      File['/usr/local/bin/rbenv-exec'],
    ],
    tag     => 'puppet',
  }

  file { [
    '/opt/rbenv/shims',
    '/opt/rbenv/versions'
  ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => [
      Exec['rbenv-download'],
    ],
    before  => [
      File['/etc/profile.d/rbenv.sh'],
    ],
    tag     => 'puppet',
  }

  file { '/etc/profile.d/rbenv.sh':
    source  => 'puppet:///modules/ruby/rbenv.sh',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => [
      Exec['rbenv-download'],
    ],
    tag     => 'puppet',
  }

  exec { 'export-rbenv-path':
    command => 'echo "source /etc/profile.d/rbenv.sh" >> /etc/bash.bashrc',
    unless  => 'grep -c "source /etc/profile.d/rbenv.sh" /etc/bash.bashrc',
    require => [
      File['/etc/profile.d/rbenv.sh'],
    ],
    tag     => 'puppet',
  }

}
