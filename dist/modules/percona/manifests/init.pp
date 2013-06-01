class percona(
  $innodb_file_per_table = true
) {
  class{'percona::install':
    innodb_file_per_table => $innodb_file_per_table,
  } ->
  class{'percona::config': } ~>
  class{'percona::service': }
}
