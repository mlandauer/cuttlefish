class utils::network {
  package { [ 'tcpdump', 'ngrep', 'mtr', 'ethtool' ]:
    ensure => present
  }

  package { [ 'netstat-nat', 'conntrack' ]:
    ensure => present
  }
}
