# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @api Private
#
class pimcore::config {
  file { '/etc/profile.d/pimcore.sh':
    ensure  => file,
    owner   => 'root',
    content => template('pimcore/pimcore.sh')
  }

  file { '/etc/redis/redis.conf':
    ensure  => file,
    owner   => root,
    content => template('pimcore/redis.conf'),
    require => Package['redis']
  }

  file { "/etc/php/${::pimcore::php_version}/${::pimcore::apache_name}/php.ini":
    ensure  => file,
    owner   => root,
    content => template('pimcore/php.ini'),
    require => Class['::php']
  }

  file { '/etc/mysql/conf.d/pimcore.cnf':
    ensure  => file,
    owner   => root,
    content => template('pimcore/pimcore.cnf')
  }
}
