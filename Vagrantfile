# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "ansible" do |ansible|
    ansible.vm.box = "bento/centos-7"
    ansible.vm.hostname = "ansible-server"
    ansible.vm.network "private_network", ip: '192.168.33.10'

    ansible.vm.provider "virtualbox" do |v|
      v.name = "Ansible-Server"
      v.memory = 1024
     # v.linked_clone = true
    end
    ansible.vm.provision "shell", path: "./provision/install_ansible.sh"

    ansible.vm.provision "shell", privileged: false, inline: <<-SHELL
      ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    SHELL
  end

  config.vm.define "node1" do |node1|
    node1.vm.box = "bento/centos-7"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: '192.168.33.15'

    node1.vm.provider "virtualbox" do |v|
      v.name = "Ansible-Node1"
      v.memory = 512
     # v.linked_clone = true
    end
    node1.vm.synced_folder '.', '/vagrant', disabled: true
  end

  config.vm.define "node2" do |node2|
    node2.vm.box = "bento/ubuntu-16.04"
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: '192.168.33.20'

    node2.vm.provider "virtualbox" do |v|
      v.name = "Ansible-Node2"
      v.memory = 512
      # v.linked_clone = true
    end
    node2.vm.synced_folder '.', '/vagrant', disabled: true
  end

  config.vm.define "node3" do |node3|
    node3.vm.box = "bento/ubuntu-18.04"
    node3.vm.hostname = "node3"
    node3.vm.network "private_network", ip: '192.168.33.30'

    node3.vm.provider "virtualbox" do |v|
      v.name = "Ansible-Node3"
      v.memory = 512
      # v.linked_clone = true
    end
    node3.vm.synced_folder '.', '/vagrant', disabled: true
  end

  config.vm.define "node4" do |node4|
    node4.vm.box = "bento/ubuntu-20.04"
    node4.vm.hostname = "node4"
    node4.vm.network "private_network", ip: '192.168.33.40'

    node4.vm.provider "virtualbox" do |v|
      v.name = "Ansible-Node4"
      v.memory = 512
      # v.linked_clone = true
    end
    node4.vm.synced_folder '.', '/vagrant', disabled: true
  end
end
