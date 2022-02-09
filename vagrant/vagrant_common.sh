#!/bin/sh
#
# Common Vagraant provisioning
#
ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/pimcore
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-mysql
puppet apply /vagrant/spec/fixtures/test.pp
