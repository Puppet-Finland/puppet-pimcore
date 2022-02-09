# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::install_configs
class pimcore::install_configs {
  file { '/etc/profile.d/pimcore.sh':
     ensure  => file,
     owner   => 'root',
     content => template('pimcore/pimcore.sh')
  }
}
