# @summary Installs skeleton and project files
#
# This uses composer to install necessary files to pimcore::app_name
#
# @api Private
#
# TODO fix console permissions
class pimcore::project {

  $create_project = [
    "/usr/local/bin/composer", "create-project",
    "pimcore/skeleton", "/opt/pimcore/${pimcore::app_name}",
  ]

  exec { 'install pimcore project skeleton':
    command  => $create_project,
    creates  => "/opt/pimcore/${pimcore::app_name}",
    cwd      => '/opt/pimcore',
    user     => $pimcore::params::web_user,
    path     => ['/usr/bin', '/usr/local/bin'],
    environment => [ 'COMPOSER_HOME=/opt/pimcore', ],
    require  => [File['/opt/pimcore'], Class['::php']],
  }->
  exec { 'install pimcore':
    command     => "/opt/pimcore/${pimcore::app_name}/vendor/bin/pimcore-install --no-interaction",
    user        => $web_user,
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

