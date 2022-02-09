# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::apache
class pimcore::apache (

  Optional[Stdlib::Absolutepath] $docroot = $pimcore::params::docroot,
  Optional[Stdlib::Port] $port            = $pimcore::params::port,


) inherits pimcore::params {
  class { '::apache':
    purge_configs => true,
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include ::apache::mod::php
  include ::apache::mod::headers
  include ::apache::mod::rewrite

  apache::vhost { $facts['fqdn']:
    servername      => $facts['fqdn'],
    port            => '80',
    docroot         => $docroot,
    directories         => [
      {
        'path'           => '/',
        'allow_override' => 'All',
      },
    ],
  }
}
