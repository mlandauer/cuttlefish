class ruby::dev {

    case $operatingsystem {
    RedHat: {
      include ruby::dev::rhel
    }
    ubuntu: {
      include ruby::dev::ubuntu
    }
    default: {
      fail("Module $module_name is not supported on $operatingsystem")
    }
  }
}

class ruby::dev::ubuntu {
  package { 'ruby-dev':
    ensure => present,
  }

}

class ruby::dev::rhel {
  package { 'ruby-devel':
    ensure => present,
  }
}
