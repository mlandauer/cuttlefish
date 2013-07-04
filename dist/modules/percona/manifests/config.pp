# takes care of percona config and log files
# including logrotate - requires https://github.com/rodjek/puppet-logrotate
#
class percona::config {
  $innodb_file_per_table = $percona::innodb_file_per_table

  file { '/etc/mysql':
    ensure => directory
  }

  #  file { '/etc/mysql/my.cnf':
  #  ensure  => present,
  #  content => template('percona/my.cnf.erb'),
  #  owner   => root,
  #  group   => admin,
  #  mode    => '0664',
  #  require => File['/etc/mysql']
  #}

  file {'/var/log/mysql':
    ensure => directory,
    owner  => 'mysql',
    group  => 'adm',
    mode   => '2750'
  }

  file {['/var/log/mysql.err', '/var/log/mysql.log']:
    ensure => present,
    owner  => 'mysql',
    group  => 'adm',
    mode   => '0640'
  }

  file {'/etc/logrotate.d/percona-server-server-5.5':
    ensure => absent,
  }

  logrotate::rule {'percona':
    path          => [
      '/var/log/mysql/*',
      '/var/log/mysql.err',
      '/var/log/mysql.log'
    ],
    rotate        => 30,
    rotate_every  => 'day',
    missingok     => true,
    create        => true,
    create_mode   => '0640',
    create_owner  => 'mysql',
    create_group  => 'adm',
    compress      => true,
    delaycompress => true,
    sharedscripts => true,
    postrotate    => 'test -x /usr/bin/mysqladmin || exit 0

    # If this fails, check debian.conf!
    MYADMIN="/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf"
    if [ -z "`$MYADMIN ping 2>/dev/null`" ]; then
      # Really no mysqld or rather a missing debian-sys-maint user?
      # If this occurs and is not a error please report a bug.
      if ps cax | grep -q mysqld; then
        exit 1
      fi
    else
      $MYADMIN flush-logs
    fi'
  }
}
