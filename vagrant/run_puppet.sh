#!/bin/sh

# Exit on any error
set -e

# Preparations required prior to "puppet apply".

usage() {
    echo
    echo "Usage: run_puppet.sh -b basedir"
    echo
    echo "Options:"
    echo " -b   Base directory for dependency Puppet modules installed by"
    echo "      librarian-puppet."
    echo " -m   Puppet manifests to run. Put them in the provision folder"
    exit 1
}

# Parse the options

# We are run without parameters -> usage
if [ "$1" = "" ]; then
    usage
fi

while getopts "b:m:h" options; do
    case $options in
        b ) BASEDIR=$OPTARG;;
	m ) MANIFESTS=$OPTARG;;
        h ) usage;;
        \? ) usage;;
        * ) usage;;
    esac
done

CWD=`pwd`

# Configure with "puppet apply"
PUPPET_APPLY="/opt/puppetlabs/bin/puppet apply --modulepath=$BASEDIR/modules"

# Pass variables to Puppet manifests via environment variables
export FACTER_profile='/etc/profile.d/openvpn.sh'
export FACTER_basedir="$BASEDIR"
export FACTER_ipa_domain="OPENVPN.VIRTUAL"
export FACTER_ipa1_fqdn="ipa1.openvpn.virtual"
export FACTER_ipa2_fqdn="ipa2.openvpn.virtual"
export FACTER_ipa3_fqdn="ipa3.openvpn.virtual"
export FACTER_ipa_admin_password="changeme"
export FACTER_ipa_diradmin_password="changeme"
export FACTER_ipa1_address="192.168.170.254"
export FACTER_ipa2_address="192.168.170.253"
export FACTER_ipa3_address="192.168.170.252"

for manifest in $MANIFESTS; do
    $PUPPET_APPLY /shared/vagrant/$manifest
done

cd $CWD
