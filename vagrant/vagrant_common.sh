#!/bin/sh
#
# Common Vagraant provisioning
#
ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/pimcore
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-mysql
puppet module install puppetlabs-apache
puppet module install puppet-php
puppet module install puppet-alternatives
puppet apply /vagrant/spec/fixtures/test.pp
