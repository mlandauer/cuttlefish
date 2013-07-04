# == Class: percona
#
# percona server is a mysql drop in replacement
#
# == Parameters
#
# [*innodb_file_per_table*]
#   boolean
#   **default** - true
#
# [*version*]
#   The package version to install.
#   **default** 'present' to install the latest package
#   'absent' to uninstall package
#   '1.0.0' to install a particula version number
#
# [*enable*]
#   Should the service be enabled during boot time?
#   **default** true
#
# [*start*]
#   Should the service be started by Puppet
#   **default** true
#
class percona
(
  $version               = 'present',
  $enable                = true,
  $start                 = true,
  $innodb_file_per_table = true
)
{
  class{'percona::apt': } ->
  class{'percona::install': } ->
  class{'percona::config': } ~>
  class{'percona::service': } ->
  Class['percona']
}
