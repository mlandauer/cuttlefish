class cuttlefish {
  include ruby::common

  $appname = 'cuttlefish'
  $base    = '/vagrant'
  $logpath = "$base/log"
  $user    = 'vagrant'

  exec { "bundle install ${appname}":
    # Horrible hack. Put the bundle cache outside of the vagrant synched directory so that
    # we don't suffer from massive performance issues.
    command   => 'rbenv exec bundle install --path /vendor-bundle',
    unless    => 'rbenv exec bundle check',
    cwd       => $base,
    logoutput => true,
    timeout   => 1800, # half an hour
    # To work around "ArgumentError: invalid byte sequence in US-ASCII" error:
    # http://stackoverflow.com/questions/14839674/bundle-install-error-invalid-byte-sequence-in-us-ascii-argumenterror
    environment => [
      'LANG=en_US.UTF-8',
      'LC_ALL=en_US.UTF-8',
      'LANGUAGE=en_US.UTF-8',
      'RBENV_ROOT=/opt/rbenv',
    ],
    path        => [
      '/bin',
      '/usr/bin',
      '/usr/local/bin',
      '/opt/rbenv/bin',
      '/opt/rbenv/shims',
    ],
    require     => [
      Class['ruby::common'],
    ]
  }

  exec { "create ${appname} database":
    command     => 'rbenv exec bundle exec rake db:setup',
    unless      => "mysqlshow -u root | grep ${appname}_development",
    cwd         => $base,
    user        => $user,
    logoutput   => true,
    environment => [
      'RBENV_ROOT=/opt/rbenv',
    ],
    path    => [
      '/bin',
      '/usr/bin',
      '/usr/local/bin',
      '/opt/rbenv/bin',
      '/opt/rbenv/shims',
    ],
    require => [
      Exec["bundle install ${appname}"],
    ]
  }

  exec { "foreman export ${appname}":
    command     => "rbenv exec bundle exec foreman export upstart /etc/init --app ${appname} --user ${user} --log ${logpath} --procfile Procfile.vagrant ",
    creates     => "/etc/init/${appname}.conf",
    logoutput   => true,
    cwd         => $base,
    environment => [
      'RBENV_ROOT=/opt/rbenv',
    ],
    path    => [
      '/bin',
      '/usr/bin',
      '/usr/local/bin',
      '/opt/rbenv/bin',
      '/opt/rbenv/shims',
    ],
    require => [
      Exec["create ${appname} database"],
    ],
  }

  service { $appname:
    ensure  => running,
    enable  => true,
    require => [
      Exec["foreman export ${appname}"],
    ]
  }
}
