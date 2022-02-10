# @summary 
#
# Params Class.
#
class pimcore::params {
  $php_version           = '8.0'
  $manage_cron           = true
  $app_name              = 'default'
  $db_name               = 'pimcore'
  $docroot               = '/var/www/html/pimcore'
  $port                  = 80
  $db_user               = 'pimcore'
  #include ::os::params

  case $::osfamily {
    'Debian': {
      $web_user = 'www-data'
    }
    default: {
      fail("Unsupported OS: ${::osfamily}")
    }
  }
}
