# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::install_project
class pimcore::install_project {

  $create_project = [
    "composer", "create-project",
    "pimcore/skeleton", "/opt/pimcore/${pimcore::app_name}",
  ]

  exec { 'install pimcore project skeleton':
    command  => $create_project,
    creates  => "/opt/pimcore/${pimcore::app_name}",
    cwd      => '/opt/pimcore',
    user     => $web_user,
    path     => ['/usr/bin', '/usr/local/bin'],
    environment => [ 'COMPOSER_HOME=/opt/pimcore', ],
    require  => [File['/opt/pimcore'], Class['::php']],
  }

#    exec { 'install pimcore':
#      command => './vendor/bin/pimcore-install --no-interaction',
#      cwd     => "opt/pimcore/${pimcore::app_name}",
#      user    => $web_user,
#      path  => ['/usr/bin', '/usr/local/bin'],
#      environment => [
#        'COMPOSER_HOME=/opt/pimcore',
#        "PIMCORE_INSTALL_MYSQL_USERNAME=${pimcore::db_user}",
#        "PIMCORE_INSTALL_MYSQL_PASSWORD=${pimcore::db_password}",
#        "PIMCORE_INSTALL_ADMIN_USERNAME=${pimcore::admin_user",
#        "PIMCORE_INSTALL_ADMIN_PASSWORD=${pimcore::admin_password}",
#      ],
#      require => File["/opt/pimcore/${pimcore::app_name}"],
#    }

  if $manage_cron {
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

