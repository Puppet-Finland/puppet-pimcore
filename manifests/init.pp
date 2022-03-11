# @summary Install full stack requirements for Pimcore
#
# This installs apache2, mysql-server, and configures/installs all
# required components that make up a base Pimcore project
#
# @example
#  class { 'pimcore':
#    root_db_pass   => 'supersecret',
#    php_settings   => {
#      'Date/date.timezone' => 'Europe/Helsinki',
#      'PHP/memory_limit'   => '512M',
#    },
#    admin_user     => 'root',
#    admin_password => 'toor',
#    db_password    => 'secret',
#  }
#
#  @param admin_user
#    The admin user required for pimcore-install step. This needs write
#    access to the project dir and /var. Currently the user will be
#    created if doesn't exist.
#  @param admin_password
#    The admin password required for pimcore-install step.
#  @param root_db_pass
#    The root user password for mysql-server
#  @param db_user
#    The user Pimcore uses to interact with the project database.
#    Default is 'pimcore'. This user has 'ALL' grant permissions.
#  @param db_password
#    The user password Pimcore uses to interact with the project database.
#  @param manage_config
#    Determines if Pimcore recommended config files will be loaded.
#    Default is 'true'.
#  @param app_name
#    The name of the applicaton. This determines the name of the
#    project folder located in /opt/pimcore/$app_name.
#  @param db_name
#    The name of the of database Pimcore uses.
#    Default is 'pimcore'.
#  @param apache_name
#    The name of the binary used by the OS.
#    Default is 'apache2'.
#  @param php_settings
#    This is a hash of settings passed to the ::php module.
#  @param php_extensions
#    A hash of extension options consumed by ::php module.
#  @param sql_override
#    Hash of sql override options consumed by ::mysql module.
#  @param manage_cron
#    Boolean for installing maintenance cron job.
#    Default is 'true'.
#  @param ssl_cert
#    The ssl cert to use for apache.
#    Default is '/etc/letsencrypt/live/${pimcore::params::dnsname}/cert.pem'
#  @param ssl_key
#    The ssl key to use for apache.
#    Default is '/etc/letsencrypt/live/${pimcore::params::dnsname}/privkey.pem'
#  @param ssl_chain
#    The ssl chain to use for apache.
#    Default is '/etc/letsencrypt/live/${pimcore::params::dnsname}/fullchain.pem'
class pimcore (
  String $admin_user,
  Variant[String, Sensitive[String]] $root_db_pass,
  Variant[String, Sensitive[String]] $admin_password,
  Variant[String, Sensitive[String]] $db_password,
  Optional[Boolean] $manage_config          = true,
  Enum['absent', 'present'] $ensure         = 'present',
  Optional[String] $app_name                = $pimcore::params::app_name,
  Optional[String] $db_name                 = $pimcore::params::db_name,
  Optional[String] $php_version             = $pimcore::params::php_version,
  Optional[String] $db_user                 = $pimcore::params::db_user,
  Optional[String] $apache_name             = $pimcore::params::apache_name,
  Optional[Stdlib::Absolutepath] $ssl_cert  = $pimcore::params::ssl_cert,
  Optional[Stdlib::Absolutepath] $ssl_key   = $pimcore::params::ssl_key,
  Optional[Stdlib::Absolutepath] $ssl_chain = $pimcore::params::ssl_chain,
  Optional[Boolean] $manage_cron            = true,
  Optional[Hash] $php_settings              = undef,
  Optional[Hash] $php_extensions            = {
    curl     => {},
    gd       => {},
    intl     => {},
    mysql    => {},
    xml      => {},
    zip      => {},
    mbstring => {},
    imagick  => {},
    pdo      => {},
    redis    => {},
  },
  Optional[Hash] $sql_override             = {
    'mysqld' => {
      'bind-address' => '127.0.0.1',
    },
  },

) inherits pimcore::params {

  if ! ($facts['os']['family'] in ['Debian']) {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only supports osfamily Debian")
  }

  user { $admin_user:
    ensure   => present,
    password => Sensitive($admin_password)
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
    composer     => false,
    dev          => false,
    fpm          => true,
    settings     => $php_settings,
    extensions   => $php_extensions,
  }~>
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
    owner  => 'root',
    group  => 'root',
  }

  package { "libapache2-mod-php${php_version}":
    ensure => installed,
    require => [ Class['::php'], Class['::apache'] ]
  }

  package { "redis":
    ensure => installed
  }

  contain pimcore::apache
  contain pimcore::project
  if $manage_config {
    contain pimcore::config
  }

}
