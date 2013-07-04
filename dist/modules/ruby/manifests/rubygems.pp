class ruby::rubygems {

  case $operatingsystem {
    ubuntu: {
      case $lsbdistcodename {
        lucid: {
          include ruby::rubygems::lucid
        }
        precise: {
          include ruby::rubygems::precise
        }
        default: {
          notify("Class ruby::rubygems is not supported on ${operatingsystem} ${lsbdistcodename}")
        }
      }
    }
    default: {
      notice("Class ruby::rubygems is not supported on ${operatingsystem}")
    }
  }
}

class ruby::rubygems::lucid {

  include ruby::common

  file { 'rubygems1.8_1.3.7-2_all.deb':
    path   => '/var/tmp/rubygems1.8_1.3.7-2_all.deb',
    source => 'puppet:///modules/ruby/rubygems1.8_1.3.7-2_all.deb',
    tag    => 'puppet',
  }

  file { 'rubygems_1.3.7-2_all.deb':
    path   => '/var/tmp/rubygems_1.3.7-2_all.deb',
    source => 'puppet:///modules/ruby/rubygems_1.3.7-2_all.deb',
    tag    => 'puppet',
  }

  exec { 'uninstall-old-rubygems':
    command => 'aptitude purge -y rubygems rubygems1.8',
    onlyif  => 'which gem && gem --version |grep 1.3.5',
    notify  => [
      Package['rubygems1.8'],
      Package['rubygems'],
    ],
    tag     => 'puppet',
  }

  package { 'rubygems1.8':
    ensure   => present,
    provider => 'dpkg',
    source   => '/var/tmp/rubygems1.8_1.3.7-2_all.deb',
    require  => [
      Exec['uninstall-old-rubygems'],
      Package['rdoc1.8'],
      Package['rdoc'],
      Package['irb1.8'],
      Package['irb'],
      Package['libreadline-ruby1.8'],
      Package['libreadline-ruby'],
      File['rubygems1.8_1.3.7-2_all.deb'],
    ],
    tag      => 'puppet',
  }

  package { 'rubygems':
    ensure   => present,
    provider => 'dpkg',
    source   => '/var/tmp/rubygems_1.3.7-2_all.deb',
    require  => [
      Exec['uninstall-old-rubygems'],
      Package['rdoc1.8'],
      Package['rdoc'],
      Package['irb1.8'],
      Package['irb'],
      Package['libreadline-ruby1.8'],
      Package['libreadline-ruby'],
      Package['rubygems1.8'],
      File['rubygems_1.3.7-2_all.deb'],
    ],
    tag      => 'puppet',
  }

  file { '/var/lib/gems/1.8/cache':
    ensure  => directory,
    owner   => root,
    group   => root,
    require => [
      Package['rubygems']
    ],
    tag     => 'puppet',
  }

  exec { 'export-rubygems-path':
    command => 'echo "export PATH=\$PATH:/var/lib/gems/1.8/bin" >> /etc/bash.bashrc',
    unless  => 'grep -c "/var/lib/gems/1.8/bin" /etc/bash.bashrc',
    require => [
      Package['rubygems'],
    ],
    tag     => 'puppet',
  }

  package { 'bundle':
    ensure   => present,
    # Use alias package on rubygems for bundler.
    # Works around this bug: http://projects.puppetlabs.com/issues/1398
    name     => 'bundle',
    provider => gem,
    require  => [
      Package['rubygems'],
      Package['ruby-dev'],
    ],
    tag      => 'puppet',
  }

}

class ruby::rubygems::precise {

  package { 'rubygems1.8':
    ensure   => present,
    tag      => 'puppet',
  }

  package { 'rubygems':
    ensure   => present,
    require  => [
      Package['rubygems1.8'],
    ],
    tag      => 'puppet',
  }

  package { 'bundle':
    ensure   => present,
    # Use alias package on rubygems for bundler.
    # Works around this bug: http://projects.puppetlabs.com/issues/1398
    name     => 'bundle',
    provider => gem,
    require  => [
      Package['rubygems'],
      Package['ruby-dev'],
    ],
    tag     => 'puppet',
  }

}

