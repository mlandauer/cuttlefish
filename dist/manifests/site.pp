Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

# Make sure package repositories are up to date before main run
stage {'before': before => Stage['main'] }
class repository { exec { 'apt-get update': } }
class {'repository': stage => 'before' }

node default {

  class {'utils':} ->
  class {'percona':} ->

  # Make sure this version matches .ruby-version
  ruby::version { '1.9.3-p392':
    is_default => true,
  } ->

  class {'postfix':} ->
  class {'cuttlefish':}
}
