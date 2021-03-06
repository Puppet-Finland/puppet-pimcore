# Installs and configures apache with ssl certs
#
# @example
#   include pimcore::apache
class pimcore::apache {

  class { '::apache':
    purge_configs => true,
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include ::apache::mod::prefork

  package { "libapache2-mod-php${php_version}":
    ensure => 'installed',
    before => Class['php'],
  }

  class { '::apache::mod::php':
    php_version => $::pimcore::params::php_version,
    path        => '/usr/lib/apache2/modules/libphp8.0.so',
  }

  include ::apache::mod::headers
  include ::apache::mod::rewrite
  include ::apache::mod::ssl
  ::apache::listen { "${pimcore::params::port}": }

  file { "/var/www/html/${::pimcore::app_name}":
    ensure => 'link',
    target => "/opt/pimcore/${::pimcore::app_name}/public",
  }

  ::apache::vhost { 'pimcore':
    ssl         => $::pimcore::ssl,
    ssl_cert    => $::pimcore::ssl_cert,
    ssl_key     => $::pimcore::ssl_key,
    ssl_chain   => $::pimcore::ssl_chain,
    port        => $::pimcore::port,
    servername  => $::pimcore::params::dnsname,
    notify      => Service[$::pimcore::params::apache_name],
    docroot     => "/var/www/html/${::pimcore::app_name}",
    directories => [
      {
      'path'           => "/var/www/html/${::pimcore::app_name}",
      'allow_override' => ['All'],
      'options'        => ['FollowSymlinks']
      },
    ],
    require     => [Package['libapache2-mod-php8.0'], File["/var/www/html/${::pimcore::app_name}"] ]
  }
}

