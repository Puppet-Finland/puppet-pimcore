$packages = [ 'curl', 'unzip', 'wget', 'git', ]


## SQL Configuration
#profile::pimcore::sql_override:
#  mysqld:
#    bind-address:         '127.0.0.1'
#
## PHP Configuration
# php::fpm:          true
# php::composer:     true
# php::settings:
# php::extensions:
#  curl:     {}
#  gd:       {}
#  intl:     {}
#  mysql:    {}
#  xml:      {}
#  zip:      {}
#  mbstring: {}
#  imagick:  {}
#
#

$sql_override = {
  'mysqld' => {
    'bind-address' => '127.0.0.1',
  },
}

package { $packages:
  ensure => 'installed',
}

class { 'mysql::server':
  root_password           => 'supersecret',
  remove_default_accounts => true,
  restart                 => true,
  override_options        => $sql_override,
}

mysql::db { 'pimcore':
  user     => 'pimcore',
  password => 'pimcore',
  host     => '127.0.0.1',
  grant    => ['ALL'],
  charset  => 'utf8mb4',
  collate  => 'utf8mb4_unicode_ci',
}

class { '::php::globals':
  php_version => '8.0',
  config_root => '/etc/php/8.0',
}->
class { '::php':
  manage_repos => true,
  composer   => true,
  dev        => false,
  fpm        => true,
  settings   => {
    'Date/date.timezone' => 'Europe/Helsinki',
    'PHP/memory_limit'   => '512M',
  },
  extensions => {
    curl     => {},
    gd       => {},
    intl     => {},
    mysql    => {},
    xml      => {},
    zip      => {},
    mbstring => {},
    imagick  => {},
  }
}

## PHP Configuration
# php::fpm:          true
# php::composer:     true
# php::settings:
#  'Date/date.timezone': 'Europe/Helsinki'
#  'PHP/memory_limit':   '512M'
# php::extensions:
#  curl:     {}
#  gd:       {}
#  intl:     {}
#  mysql:    {}
#  xml:      {}
#  zip:      {}
#  mbstring: {}
#  imagick:  {}
#
#


class { '::apache':
  purge_configs => true,
  default_vhost => false,
  mpm_module    => 'prefork',
}

include ::apache::mod::php
include ::apache::mod::headers
include ::apache::mod::rewrite

alternatives { 'php':
  path     => '/usr/bin/php8.0',
  require  => Class['::php']
}

apache::vhost { $facts['fqdn']:
  servername      => $facts['fqdn'],
  port            => '80',
  docroot         => '/var/www/html/pimcore',
  directories         => [
    {
      'path'           => '/',
      'allow_override' => 'All',
    },
  ],
}

file { '/opt/pimcore':
  ensure => 'directory',
  owner  => 'www-data',
  group  => 'www-data',
}

$create_project = [
  "/usr/local/bin/composer", "create-project",
  "pimcore/skeleton", "/opt/pimcore/default",
]

exec { 'pimcore':
  command  => $create_project,
  creates  => '/opt/pimcore/default',
  cwd      => '/opt/pimcore',
  user     => 'www-data',
  path     => ['/usr/bin'],
  environment => [ 'COMPOSER_HOME=/opt/pimcore', ],
  subscribe => [ Class['php'], File['/opt/pimcore' ] ]
}

file { '/var/www/html/pimcore':
  ensure  => 'link',
  target  => '/opt/pimcore/public',
  require => [
    Apache::Vhost[$facts['fqdn']],
  ]
}

