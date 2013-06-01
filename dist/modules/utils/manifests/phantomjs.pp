# ensure phantomjs is installed
#
class utils::phantomjs {
  package { 'phantomjs':
    ensure => installed,
  }
}
