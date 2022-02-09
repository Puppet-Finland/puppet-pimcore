# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore
class pimcore (

  Variant[String, Sensitive[String]] $root_db_pass,
  Optional[String] $app_name        = 'default',
  Enum['absent', 'present'] $ensure = 'present',
  Optional[String] $php_version     = $pimcore::params::php_version,
  Optional[Hash] $php_settings      = $pimcore::params::php_settings,
  Optional[Hash] $php_extensions    = {
    curl     => {},
    gd       => {},
    intl     => {},
    mysql    => {},
    xml      => {},
    zip      => {},
    mbstring => {},
    imagick  => {},
  },
  Optional[Hash] $sql_override      = {
    'mysqld' => {
      'bind-address' => '127.0.0.1',
    },
  },

) inherits pimcore::params {

  if ! ($facts['os']['family'] in ['Debian']) {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only supports osfamily Debian")
  }

  class { 'mysql::server':
    root_password           => $root_db_pass,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => $sql_override,
  }

  class { '::php::globals':
    php_version => $php_version,
    config_root => "/etc/php/${php_version}",
  }->
  class { '::php':
    manage_repos => true,
    composer     => true,
    dev          => false,
    fpm          => true,
    settings     => $php_settings,
    extensions   => $php_extensions,
  }

  alternatives { 'php':
    path     => "/usr/bin/php${php_version}",
    require  => Class['::php']
  }

  include pimcore::apache
  include pimcore::install_configs
}
