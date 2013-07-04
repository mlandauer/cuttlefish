class utils::vim {

  if ($::operatingsystem == RedHat) {
    file { '/etc/vim':
      ensure  =>  directory,
      before  =>  File['/etc/vim/vimrc.local'],
    }
  }

  $package = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'vim',
    /Redhat/                  => 'vim-enhanced',
    default                   => 'vim',
  }

  package { 'vim':
    ensure => present,
    name   => $package,
  }

  file { '/etc/vim/vimrc.local':
    source  => 'puppet:///modules/utils/etc/vim/vimrc.local',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => [
      Package['vim']
    ]
  }

  package { 'nano':
    ensure  => absent,
    require => Package['vim'],
  }
}
