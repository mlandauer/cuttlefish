Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

# Make sure package repositories are up to date before main run

node default {

  # Make sure package repositories are up to date before main run
  #
  Apt::Source <| |> -> Package <| |>

  class {'utils':} ->

  # Make sure this version matches .ruby-version
  ruby::version { '1.9.3-p392':
    is_default => true,
  } ->
  class {'postfix':} ->
  class {'percona':} ->
  class {'cuttlefish':}
}
