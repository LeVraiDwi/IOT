# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # lastest stable version Debian box from Vagrant cloud
  config.vm.box = "debian/bookworm64"
  
  # Define first machine (Server)
  config.vm.define "tcosseS" do |node|
    node.vm.hostname = "tcosseS"
    node.vm.network "private_network", ip: "192.168.56.110"
    node.vm.disk :disk, size: "10GB", primary: true

    node.vm.provider "virtualbox" do |vb|
      vb.name = "tcosse-server"
      vb.memory = 512
      vb.cpus = 1
    end

    # No-password SSH (public key automatically managed by Vagrant)
    node.ssh.insert_key = true
  end

  # Define second machine (ServerWorker)
  config.vm.define "mtsujiSW" do |node|
    node.vm.hostname = "mtsujiSW"
    node.vm.network "private_network", ip: "192.168.56.111"
    node.vm.disk :disk, size: "10GB", primary: true

    node.vm.provider "virtualbox" do |vb|
      vb.name = "mtsuji-worker"
      vb.memory = 512
      vb.cpus = 1
    end

    # No-password SSH
    node.ssh.insert_key = true
  end
end
