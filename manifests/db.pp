# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   pimcore::db { 'dbname':
#   }
define pimcore::db (
  String $user,
  Variant[String, Sensitive[String]] $password,
  Enum['absent', 'present'] $ensure = 'present',
  String $dbname                    = $name,
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
