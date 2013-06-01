# installs specified version of ruby with rbenv
define ruby::version($is_default=false) {
  include ruby::common

  $version = $name

  if $version =~ /jruby/ {
    include java::jdk
  }

  exec { "rbenv-install-${version}":
    alias       => "ruby-${version}",
    environment => 'RBENV_ROOT=/opt/rbenv',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
    command     => "/opt/rbenv/bin/rbenv install ${version}",
    creates     => "/opt/rbenv/versions/${version}",
    timeout     => 900, # allow 15 minutes to build ruby
    require     => [
      Exec['rbenv-download'],
      Package['curl'],
    ],
  }

  package { "bundler/${version}":
    ensure   => present,
    #name     => 'bundler',
    provider => rbenvgem,
    #alias    => "bundler-${version}",
    require  => [
      Exec["rbenv-install-${version}"],
    ],
  }

  if $is_default {
    file { '/opt/rbenv/global':
      content => "${version}\n",
      group   => 'admin',
      require => [
        Exec["rbenv-install-${version}"],
        Group['admin'],
      ],
    }
  }

}
