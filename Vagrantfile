# -*- mode: ruby -*-

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define "pimcore" do |box|
    box.vm.box = "ubuntu/focal64"
    config.vm.box_version = "20211026.0.0"
    box.vbguest.installer_options = { allow_kernel_upgrade: true }
    box.vm.hostname = 'pimcore.virtual'
    box.vm.synced_folder '.', '/vagrant', type: "virtualbox"
    box.vm.network "private_network", ip: "192.168.56.71"
    box.vm.network "forwarded_port", guest: 80, host: 8080
    box.vm.provider 'virtualbox' do |vb|
      vb.gui = false
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--nictype1", "virtio" ]
      vb.customize ["modifyvm", :id, "--nictype2", "virtio" ]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
  end

  config.vm.provision "shell", path: "./vagrant/install_agent.sh"
  config.vm.provision "shell", path: "./vagrant/vagrant_common.sh"
end

