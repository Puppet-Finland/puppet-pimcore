notify { 'Preparing for setup': }

$tools = [
  'emacs-nox', 'tcpdump', 'strace', 'nmap',
  'screen', 'net-tools', 'usbutils', 'git', 'vim'
]

package { $tools:
  ensure  => 'installed',
}

package { 'r10k':
  ensure   => 'present',
  provider => 'puppet_gem',
}

exec { 'Update modules':
  cwd       => "${::basedir}/vagrant",
  logoutput => true,
  command   => 'r10k puppetfile install --verbose',
  timeout   => 600,
  path      => ['/bin','/usr/bin','/opt/puppetlabs/bin','/opt/puppetlabs/puppet/bin'],
}

# Remove hostname from 127.0.0.1
augeas { 'localhost':
  changes => [
    "rm /files/etc/hosts/1",
  ],
}

host { 'localhost.localdomain':
  ensure => present,
  ip     => "127.0.0.1",
}

file { 'pimcore_module':
  path   => "${::basedir}/vagrant/modules/pimcore",
  ensure => 'link',
  target => '/shared',
}
