# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pimcore::db
class pimcore::db (
  String $user,
  String $name,
  Variant[String, Sensitive[String]] $password,
  Enum['absent', 'present'] $ensure = 'present',
  String $host                      = '127.0.0.1',
  Array  $grant                     = ['ALL'],
){
  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant,
    charset  => 'utf8mb4',
    collate  => 'utf8mb4_unicode_ci',
  }
}
