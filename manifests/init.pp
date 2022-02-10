# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore
class pimcore (

  String $admin_user,
  Variant[String, Sensitive[String]] $root_db_pass,
  Variant[String, Sensitive[String]] $admin_password,
  Variant[String, Sensitive[String]] $db_password,
  Enum['absent', 'present'] $ensure = 'present',
  Optional[String] $app_name        = $pimcore::params::app_name,
  Optional[String] $db_name         = $pimcore::params::db_name,
  Optional[String] $php_version     = $pimcore::params::php_version,
  Optional[String] $db_user         = $pimcore::params::db_user,
  Optional[Hash] $php_settings      = undef,
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
    require  => [ Class['::php'] ]
  }

  pimcore::db { $db_name:
    ensure   => $ensure,
    user     => $db_user,
    password => $db_password,
  }

  file { '/opt/pimcore':
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
  }

  contain pimcore::apache
  contain pimcore::install_project
  contain pimcore::install_configs

}
