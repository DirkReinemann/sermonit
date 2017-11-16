# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.hostname = "vagrant"
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision "file", source: "sermonit.zip", destination: "sermonit.zip"

  config.vm.provision "shell", inline: <<-SHELL
    pacman -Sy
    pacman -S --noconfirm apache unzip make gcc jq scala jdk8-openjdk perl ruby go rust bash-completion net-tools
    unzip sermonit.zip
    make install
    make service
  SHELL
end
