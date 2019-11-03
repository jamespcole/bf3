################################################################################
# BF3 VAGRANT BOX
#
# This vagrant file is used to create a dev environment for working on the
# BF3 project.
################################################################################

scriptsDir = $scriptsDir ||= File.expand_path("scripts/vagrant", File.dirname(__FILE__))

# Does the app specific provisioning steps
afterScriptPath = scriptsDir + '/start_provisioning.sh'

# Specify the base box
baseBox = 'bento/ubuntu-18.04'

$msg = <<MSG
------------------------------------------------------
BF3 - development environment

COMMANDS:
 - bf3 --run <your module>
 - bf3_env --info

------------------------------------------------------
MSG

Vagrant.configure("2") do |config|
    config.vm.box = baseBox
    config.vm.box_version = '>=201906.18.0'
    config.vm.post_up_message = $msg
    # config.vm.network "public_network"

    # Setup synced folder
    config.vm.synced_folder ".", "/home/vagrant/app"

    # VM specific configs
    config.vm.provider "virtualbox" do |v|
        v.name = "bf3-devbox"
        v.customize ["modifyvm", :id, "--memory", "1512"]
        v.cpus = 2
    end

    # On initial provisioning apt installs will often fail if apt-get update
    # has never been run so we call it before the other scripts.
    # config.vm.provision "shell",
    #     inline: "sudo apt-get update && sudo groupadd docker && sudo usermod -aG docker $USER",
    #     privileged: false,
    #     reset: true

    if File.exists? afterScriptPath then
        config.vm.provision "shell",
            path: afterScriptPath,
            privileged: false
    end

end
