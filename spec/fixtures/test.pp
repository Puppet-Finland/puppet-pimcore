class { 'pimcore':
  root_db_pass => 'supersecret',
  php_settings => {
    'Date/date.timezone' => 'Europe/Helsinki',
    'PHP/memory_limit'   => '512M',
  },
}

pimcore::db { 'pimcore':
   user     => 'pimcore',
   password => 'pimcore',
}
