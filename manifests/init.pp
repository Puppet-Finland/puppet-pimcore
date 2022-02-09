# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore
class pimcore (
  Variant[String, Sensitive[String]] $root_db_pass,
  Enum['absent', 'present'] $ensure = 'present',
  String $php_version = '8.0',
) inherits pimcore::params {
  if ! ($facts['os']['family'] in ['Debian']) {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only supports osfamily Debian")
  }

  class { 'mysql::server':
    root_password => $root_db_pass,
    remove_default_accounts => true,
    restart => true,
    override_options => {
      'mysqld' => {
        'bind-address' => '127.0.0.1',
      },
    },
  }
}
