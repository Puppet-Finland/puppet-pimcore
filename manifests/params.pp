# @summary Params class
#
class pimcore::params {
  $php_version           = '8.0'
  $manage_cron           = true
  $app_name              = 'default'
  $db_name               = 'pimcore'
  $port                  = '80'
  $db_user               = 'pimcore'

  case $::osfamily {
    'Debian': {
      $web_user    = 'www-data'
      $apache_name = 'apache2'
    }
    default: {
      fail("Unsupported OS: ${::osfamily}")
    }
  }
}
