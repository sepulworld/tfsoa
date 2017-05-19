# -*- mode: ruby -*-
# vi: set ft=ruby :

# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 9292, host: 9292
  config.vm.provision "shell", path: "local_dev.sh"
end
