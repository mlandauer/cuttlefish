# installs specified version of ruby with rbenv
define ruby::version($is_default=false) {
  include ruby::common

  $version          = $name
  $rubygems_version = '2.0.3'

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

  exec { "update-rubygems-for-ruby-${version}":
    # FIXME(auxesis): use plain `rbenv exec`? like in cuttlefish module
    command     => "rbenv-exec gem update --system ${rubygems_version}",
    unless      => "rbenv-exec gem --version |grep -q ${rubygems_version}",
    environment => 'RBENV_ROOT=/opt/rbenv',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
    require     => [
      Exec["rbenv-install-${version}"],
    ],
  }

  package { "bundler/${version}":
    ensure   => present,
    provider => rbenvgem,
    require  => [
      Exec["update-rubygems-for-ruby-${version}"],
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
      before  => [
        Exec["update-rubygems-for-ruby-${version}"],
      ]
    }
  }

}
