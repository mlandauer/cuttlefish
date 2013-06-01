# Distibute a profile.d file 
# that extends the FACTLIB env variable.
#
class utils::facterpath {
  file {'/etc/profile.d/facter.sh':
    ensure  => present,
    mode    => '0644',
    content => 'export FACTERLIB=/var/lib/puppet/lib',
  }
}
