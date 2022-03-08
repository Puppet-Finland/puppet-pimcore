# @summary Installs skeleton and project files
#
# This uses composer to install necessary files to pimcore::app_name
#
# @api Private
#
class pimcore::project {

  $create_project = [
    "/usr/local/bin/composer", "create-project",
    "pimcore/skeleton", "/opt/pimcore/${pimcore::app_name}",
  ]

  exec { 'install pimcore project skeleton':
    command  => $create_project,
    creates  => "/opt/pimcore/${pimcore::app_name}",
    cwd      => '/opt/pimcore',
    user     => 'root',
    path     => ['/usr/bin', '/usr/local/bin'],
    environment => [ 'COMPOSER_HOME=/opt/pimcore', 'COMPOSER_ALLOW_SUPERUSER=1'],
    require  => [File['/opt/pimcore'], Class['::php']],
    before   => File["/opt/pimcore/${pimcore::app_name}/vendor"]
  }

  file { "/opt/pimcore/${pimcore::app_name}/vendor":
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => Exec['install pimcore project skeleton'],
    before  => Exec['install pimcore']
  }

  exec { 'install pimcore':
    command     => "/opt/pimcore/${pimcore::app_name}/vendor/bin/pimcore-install --no-interaction",
    user        => 'root',
    logoutput   => true,
    creates     => "/opt/pimcore/${pimcore::app_name}/var/config/system.yml",
    path        => ['/usr/bin', '/usr/local/bin'],
    environment => [
      'COMPOSER_HOME=/opt/pimcore',
      "PIMCORE_INSTALL_MYSQL_USERNAME=${pimcore::db_user}",
      "PIMCORE_INSTALL_MYSQL_PASSWORD=${pimcore::db_password}",
      "PIMCORE_INSTALL_MYSQL_DATABASE=${pimcore::db_name}",
      "PIMCORE_INSTALL_ADMIN_USERNAME=${pimcore::admin_user}",
      "PIMCORE_INSTALL_ADMIN_PASSWORD=${pimcore::admin_password}",
    ],
    require => File["/opt/pimcore/${pimcore::app_name}/vendor"]
  }

  file { "/opt/pimcore/${pimcore::app_name}/var":
    ensure   => 'directory',
    mode     => '0755',
    owner    => $pimcore::params::web_user,
    group    => $pimcore::params::web_user,
    recurse  => true,
    require  => Exec['install pimcore'],
    notify   => Service[$pimcore::params::apache_name]
  }

  file { "/opt/pimcore/${pimcore::app_name}/public":
    ensure   => 'directory',
    mode     => '0755',
    owner    => $pimcore::params::web_user,
    group    => $pimcore::params::web_user,
    recurse  => true,
    require  => Exec['install pimcore'],
    notify   => Service[$pimcore::params::apache_name]
  }

  file { "/opt/pimcore/${pimcore::app_name}/bin":
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'www-data',
    recurse => true,
    require => Exec['install pimcore']
  }

  file { '/var/lib/php':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

  file { "/var/lib/php/sessions":
    ensure  => 'directory',
    mode    => '0655',
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => File['/var/lib/php'],
  }

  file { "/root/install_composer.sh":
    ensure  => 'present',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('pimcore/install_composer.sh'),
    before  => Exec['/root/install_composer.sh']
  }

  exec { '/root/install_composer.sh':
    creates   => '/usr/local/bin/composer',
    user      => 'root',
    logoutput => true,
    require   => [Class['::php'], File['/root/install_composer.sh']],
  }

  if ($pimcore::manage_cron) {
    cron::job::multiple { 'maintenance':
        jobs => [
          {
            minute  => '*/5',
            hour    => '*',
            date    => '*',
            month   => '*',
            weekday => '*',
            user    => 'www-data',
            command => '/opt/pimcore/bin/console pimcore:maintenance',
          },
          {
            command => '/opt/pimcore/bin/console messenger:consume pimcore_core pimcore_maintenance --time-limit=300',
            minute  => '*/5',
            hour    => '*',
            date    => '*',
            month   => '*',
            weekday => '*',
            user    => 'www-data',
          }
        ]
      }
    }
  }

