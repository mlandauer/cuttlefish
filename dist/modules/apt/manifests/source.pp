# source.pp
# add an apt source

define apt::source(
  $ensure = present,
  $location = '',
  $release = $lsbdistcodename,
  $repos = 'main',
  $include_src = true,
  $required_packages = false,
  $key = false,
  $key_server = 'keyserver.ubuntu.com',
  $key_content = false,
  $key_source  = false,
  $pin = false
) {

  include apt::params
  include apt::update

  $sources_list_d = $apt::params::sources_list_d
  $provider       = $apt::params::provider

  if $release == undef {
    fail('lsbdistcodename fact not available: release parameter required')
  }

  file { "${name}.list":
    ensure  => $ensure,
    path    => "${sources_list_d}/${name}.list",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/source.list.erb"),
    notify  => Exec['apt_update'],
  }

  if ($pin != false) and ($ensure == 'present') {
    apt::pin { $release:
      priority => $pin,
      before   => File["${name}.list"]
    }
  }

  if ($required_packages != false) and ($ensure == 'present') {
    exec { "Required packages: '${required_packages}' for ${name}":
      command     => "${provider} -y install ${required_packages}",
      subscribe   => File["${name}.list"],
      refreshonly => true,
    }
  }

  # We do not want to remove keys when the source is absent.
  if ($key != false) and ($ensure == 'present') {
    apt::key { "Add key: ${key} from Apt::Source ${title}":
      ensure      => present,
      key         => $key,
      key_server  => $key_server,
      key_content => $key_content,
      key_source  => $key_source,
      before      => File["${name}.list"],
    }
  }
}
