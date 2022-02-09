# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::params
class pimcore::params {
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
