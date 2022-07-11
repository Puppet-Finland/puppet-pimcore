class { 'pimcore':
  root_db_pass   => 'supersecret',
  php_settings   => {
    'Date/date.timezone' => 'Europe/Helsinki',
    'PHP/memory_limit'   => '512M',
  },
  admin_user     => 'root',
  admin_password => 'toor',
  db_password    => 'secret',
  ssl            => false,
  port           => 80,
}
