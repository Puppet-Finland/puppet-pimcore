# A description of what this class does
#
# @example
#   include pimcore::apache
class pimcore::apache {
  if (versioncmp($pimcore::params::php_version, '8.1') < 0) {
    $mod = "php${pimcore::params::php_version}"
  } else {
    $mod = "php"
  }

  class { '::apache':
    purge_configs => true,
    default_vhost => false,
    mpm_module    => 'prefork',
  }-> # Hack to get version 8.0 loaded
  exec { "a2enmod php":
    command => "/usr/sbin/a2enmod ${mod}",
    require => Class['::php']
  }
  # Currently there is a bug where 8.0 is considered the latest and the
  # php name gets messed up
  # class { '::apache::mod::php':
  #   php_version => $pimcore::params::php_version,
  # }

  include ::apache::mod::headers
  include ::apache::mod::rewrite
  apache::listen { $pimcore::params::port: }

  $epp_config = { 'app_name' => $pimcore::app_name }
  apache::vhost::custom { 'pimcore':
    content => epp('pimcore/apache2.conf.epp', $epp_config)
  }->
  file { "/var/www/html/${pimcore::app_name}":
    ensure  => 'link',
    target  => "/opt/pimcore/${pimcore::app_name}/public",
  }
}

