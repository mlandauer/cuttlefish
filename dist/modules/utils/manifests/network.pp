class utils::network {
  package { [
    'tcpdump',
    'ngrep',
    'ethtool',
    'nmap',
  ]:
    ensure => present
  }
}
