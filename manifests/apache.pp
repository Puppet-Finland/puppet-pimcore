# Installs and configures apache with ssl certs
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
  include ::apache::mod::ssl
  apache::listen { $pimcore::params::port: }

  file { "/var/www/html/${pimcore::app_name}":
    ensure  => 'link',
    target  => "/opt/pimcore/${pimcore::app_name}/public",
  }

  apache::vhost { 'pimcore':
    ssl         => true,
    ssl_cert    => $pimcore::ssl_cert,
    ssl_key     => $pimcore::ssl_key,
    ssl_chain   => $pimcore::ssl_chain,
    port        => '443',
    servername  => $pimcore::params::dnsname,
    notify      => Service[$pimcore::params::apache_name],
    docroot     => "/var/www/html/${pimcore::app_name}",
    directories => [
      {
      'path'           => "/var/www/html/${pimcore::app_name}",
      'allow_override' => ['All'],
      'options'        => ['FollowSymlinks']
      },
    ],
    require     => File["/var/www/html/${pimcore::app_name}"]
  }
}

