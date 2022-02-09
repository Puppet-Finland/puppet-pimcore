# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::params
class pimcore::params (

  Optional[Stdlib::Absolutepath] $docroot = '/var/www/html/pimcore',
  Optional[Stdlib::Port] $port            = 80,
  Optional[String] $php_version           = '8.0',
  Optional[Hash] $php_settings            = {
   'Date/date.timezone' => 'Europe/Helsinki',
   'PHP/memory_limit'   => '512M',
  },

){
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
