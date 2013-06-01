# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box       = 'precise64'
  config.vm.box_url   = 'http://files.vagrantup.com/precise64.box'
  config.vm.host_name = 'cuttlefish.example.org'

  config.vm.forward_port 3000, 3000

  config.vm.provision :puppet do |puppet|
    puppet.module_path    = 'dist/modules'
    puppet.manifests_path = 'dist/manifests'
    puppet.manifest_file  = 'site.pp'
  end
end

