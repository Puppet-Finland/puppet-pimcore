# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::apache
class pimcore::apache inherits pimcore::params {
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
    port            => $port,
    docroot         => "/var/www/html/${app_name}",
    directories         => [
      {
        'path'           => '/',
        'allow_override' => 'All',
      },
    ],
  }

  file { "/var/www/html/${app_name}":
    ensure  => 'link',
    target  => "/opt/pimcore/${app_name}/public",
    require => Apache::Vhost[$facts['fqdn']],
  }
}
