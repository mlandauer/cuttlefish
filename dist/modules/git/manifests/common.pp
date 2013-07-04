class git::common {

  case $operatingsystem {
    RedHat: {
      include git::common::rhel
    }
    ubuntu: {
      include git::common::ubuntu
    }
    default: {
      fail("Module $module_name is not supported on $operatingsystem")
    }
  }



  file { "/etc/gitconfig":
    source => "puppet:///modules/git/etc/gitconfig",
    mode   => 644,
    owner  => root,
    group  => root
  }
}


class git::common::ubuntu {

  case $lsbdistcodename {
    lucid: {
      package { 'git-core':
        ensure => present,
        alias  => 'git'
      }
    }
    default: {
      package { 'git':
        ensure => present,
      }
    }
  }
}

class git::common::rhel {
  package { 'git':
    ensure => present,
  }
}

