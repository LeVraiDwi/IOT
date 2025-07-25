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
  config.vm.define "tcosseS" do |serveur|
    serveur.vm.hostname = "tcosseS"
    serveur.vm.network "private_network", ip: "192.168.56.110"
    serveur.vm.disk :disk, size: "10GB", primary: true

    serveur.vm.provider "virtualbox" do |vb|
      vb.name = "tcosse-server"
      vb.memory = 512
      vb.cpus = 1
    end
    serveur.ssh.insert_key = true
    
    # Install K3s server (controller mode)
    serveur.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get install -y curl
      curl -sfL https://get.k3s.io | sh -
    SHELL

    # No-password SSH (public key automatically managed by Vagrant)
  end

  # Define second machine (ServerWorker)
  config.vm.define "mtsujiSW" do |worker|
    worker.vm.hostname = "mtsujiSW"
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.disk :disk, size: "10GB", primary: true

    worker.vm.provider "virtualbox" do |vb|
      vb.name = "mtsuji-worker"
      vb.memory = 512
      vb.cpus = 1
    end
    worker.ssh.insert_key = true
    
    # Wait for the server to be ready, then install K3s agent
    worker.vm.provision "shell", inline: <<-SHELL
      # Wait for the server
      until nc -z 192.168.56.110 6443; do sleep 1; done
      sudo apt-get update -y
      sudo apt-get install -y curl
      # Fetch the K3s token from the server via SSH
      TOKEN=$(ssh -o StrictHostKeyChecking=no vagrant@192.168.56.110 "sudo cat /var/lib/rancher/k3s/server/node-token")

      # Install the agent and connect to the server
      curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -
    SHELL
    
    # No-password SSH
  end
end
