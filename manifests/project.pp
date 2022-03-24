# @summary Installs skeleton and project files
#
# This uses composer to install necessary files to pimcore::app_name
#
# @api Private
#
class pimcore::project {

  $project_dir = "/opt/pimcore/${::pimcore::app_name}"

  file { "/root/install_composer.sh":
    ensure  => 'present',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('pimcore/install_composer.sh'),
    before  => Exec['/root/install_composer.sh']
  }

  exec { '/root/install_composer.sh':
    creates     => '/usr/local/bin/composer',
    user        => 'root',
    logoutput   => true,
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
    environment => [ 'COMPOSER_HOME=/root/.composer' ],
    require     => [Class['::php'], File['/root/install_composer.sh']],
  }

  if $::pimcore::git_url {
    $pimcore_require = Exec['composer install']

    vcsrepo { $project_dir:
      ensure   => 'present',
      provider => git,
      source   => $::pimcore::git_url,
    }

    file { "${project_dir}/.env":
      ensure  => file,
      require => Vcsrepo[$project_dir],
    }

    exec {
      default:
        cwd         => '/opt/pimcore/default',
        user        => 'root',
        path        => ['/usr/bin', '/usr/local/bin'],
        environment => [ 'COMPOSER_HOME=/opt/pimcore', 'COMPOSER_ALLOW_SUPERUSER=1'],
        refreshonly => true,
        require     => Exec['/root/install_composer.sh'],
      ;
      ['composer update']:
        command   => 'composer update',
        subscribe => File["${project_dir}/.env"],
      ;
      ['composer install']:
        command   => 'composer install',
        subscribe => Exec['composer update'],
      ;
    }
  } else {
    $pimcore_require = Exec['install pimcore project skeleton']

    $create_project = [
      "/usr/local/bin/composer", "create-project",
      "pimcore/skeleton", $project_dir,
    ]

    exec { 'install pimcore project skeleton':
      command     => $create_project,
      creates     => $project_dir,
      cwd         => '/opt/pimcore',
      user        => 'root',
      path        => ['/usr/bin', '/usr/local/bin'],
      environment => [ 'COMPOSER_HOME=/opt/pimcore', 'COMPOSER_ALLOW_SUPERUSER=1'],
      require     => [File['/opt/pimcore'], Exec['/root/install_composer.sh']],
      before      => File["/opt/pimcore/${pimcore::app_name}/vendor"],
    }
  }

  exec { 'set vendor permissions':
    command     => "chown --changes -R ${::pimcore::params::web_user}:${::pimcore::params::web_user} ${project_dir}/vendor",
    user        => 'root',
    path        => ['/usr/bin', '/usr/local/bin'],
    refreshonly => true,
    require     => $pimcore_require,
    subscribe   => $pimcore_require,
    before      => Exec['install pimcore']
  }

  exec { 'install pimcore':
    command     => "${project_dir}/vendor/bin/pimcore-install --no-interaction",
    user        => 'root',
    logoutput   => true,
    creates     => "${project_dir}/var/config/system.yml",
    path        => ['/usr/bin', '/usr/local/bin'],
    environment => [
      'COMPOSER_HOME=/opt/pimcore',
      "PIMCORE_INSTALL_MYSQL_USERNAME=${pimcore::db_user}",
      "PIMCORE_INSTALL_MYSQL_PASSWORD=${pimcore::db_password}",
      "PIMCORE_INSTALL_MYSQL_DATABASE=${pimcore::db_name}",
      "PIMCORE_INSTALL_ADMIN_USERNAME=${pimcore::admin_user}",
      "PIMCORE_INSTALL_ADMIN_PASSWORD=${pimcore::admin_password}",
    ],
    require     => [Exec['set vendor permissions'], $pimcore_require],
    notify      => Exec['set pimcore permissions'], 
  }

  exec { 'set pimcore permissions':
    command     => "chown -R ${::pimcore::params::web_user}:${::pimcore::params::web_user} ${project_dir}/public ${project_dir}/var",
    user        => 'root',
    path        => ['/usr/bin', '/usr/local/bin'],
    refreshonly => true,
    require     => Exec['install pimcore'],
  }

  file { "${project_dir}/bin":
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
    mode    => '1733',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    require => File['/var/lib/php'],
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

