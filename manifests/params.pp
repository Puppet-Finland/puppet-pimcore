# @summary Params class
#
class pimcore::params {
  $php_version           = '8.0'
  $manage_cron           = true
  $app_name              = 'default'
  $db_name               = 'pimcore'
  $port                  = '443'
  $db_user               = 'pimcore'
  $dnsname               = $::fqdn
  $ssl_cert              = "/etc/letsencrypt/live/${pimcore::params::dnsname}/cert.pem"
  $ssl_key               = "/etc/letsencrypt/live/${pimcore::params::dnsname}/privkey.pem"
  $ssl_chain             = "/etc/letsencrypt/live/${pimcore::params::dnsname}/fullchain.pem"

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
