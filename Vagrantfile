# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "vagrant"
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision "file", source: "sermonit.zip", destination: "sermonit.zip"

  config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     apt-get install -y apache2 unzip make gcc jq python scala openjdk-8-jre go rust perl ruby
     unzip sermonit.zip
     make install
     make service
  SHELL
end
