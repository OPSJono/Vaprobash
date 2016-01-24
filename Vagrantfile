# -*- mode: ruby -*-
# vi: set ft=ruby :

# Root of project folder
# Set this to the root of the InnovedV2API folder on your machine.
project_folder = "A:/Code/vle2"

# Config Github Settings
github_username = "OPSJono"
github_repo     = "Vaprobash"
github_branch   = "innoved"
github_url      = "https://raw.githubusercontent.com/#{github_username}/#{github_repo}/#{github_branch}"

# Server Configuration

hostname        = "auto.InnovedV2API.vm"

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip             = "192.168.22.10"
server_cpus           = "1"   # Cores
server_memory         = "1024" # MB
server_swap           = "2048" # Options: false | int (MB) - Guideline: Between one or two times the server_memory

# UTC        for Universal Coordinated Time
# EST        for Eastern Standard Time
# CET        for Central European Time
# US/Central for American Central
# US/Eastern for American Eastern
server_timezone  = "UTC"

# Database Configuration
mysql_root_password   = "root"   # We'll assume user "root"
mysql_version         = "5.6"    # Options: 5.5 | 5.6
mysql_enable_remote   = "false"  # remote access enabled when true

# Languages and Packages
php_timezone          = "UTC"    # http://php.net/manual/en/timezones.php
php_version           = "5.6"    # Options: 5.5 | 5.6
ruby_version          = "latest" # Choose what ruby version should be installed (will also be the default version)
ruby_gems             = [        # List any Ruby Gems that you want to install
  #"jekyll",
  #"sass",
  #"compass",
]

go_version            = "latest" # Example: go1.4 (latest equals the latest stable version)

# To install HHVM instead of PHP, set this to "true"
hhvm                  = "false"

# PHP Options
composer_packages     = [        # List any global Composer packages that you want to install
  #"phpunit/phpunit:4.0.*",
  #"codeception/codeception=*",
  #"phpspec/phpspec:2.0.*@dev",
  #"squizlabs/php_codesniffer:1.5.*",
]

public_folder         = "/var/www/html"


Vagrant.configure("2") do |config|

  # Set server to Ubuntu 15.04
  config.vm.box = "ubuntu/trusty64"

  config.vm.define "Innoved VM" do |vapro|
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
  end

  # Create a static IP
  if Vagrant.has_plugin?("vagrant-auto_network")
    config.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
  else
    config.vm.network :private_network, ip: server_ip
    config.vm.network :forwarded_port, guest: 80, host: 8000
  end

  # Enable agent forwarding over SSH connections
  config.ssh.forward_agent = true

  # Use NFS for the shared folder
  config.vm.synced_folder project_folder, "/srv",
    id: "core",
    :nfs => true,
    :mount_options => ['rw']

  # Replicate local .gitconfig file if it exists
  if File.file?(File.expand_path("~/.gitconfig"))
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  end

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|

    vb.name = hostname

    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", server_cpus]

    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", server_memory]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

  end

  ####
  # Base Items
  ##########

  # Fix "stdin is not a tty" error message when provisioning.
  # Ref: http://foo-o-rama.com/vagrant--stdin-is-not-a-tty--fix.html
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Provision Base Packages
  config.vm.provision "shell", path: "scripts/base.sh", args: [github_url, server_swap, server_timezone]

  # optimize base box
  config.vm.provision "shell", path: "scripts/base_box_optimizations.sh", privileged: true

  # Provision PHP
  config.vm.provision "shell", path: "scripts/php.sh", args: [php_timezone, hhvm, php_version]

  # Provision Vim
  config.vm.provision "shell", path: "scripts/vim.sh", args: github_url

  ####
  # Web Servers
  ##########

  # Provision Apache Base
  config.vm.provision "shell", path: "scripts/apache.sh", args: [server_ip, public_folder, hostname, github_url]

  # Provision Nginx Base
  # config.vm.provision "shell", path: "scripts/nginx.sh", args: [server_ip, public_folder, hostname, github_url]


  ####
  # Databases
  ##########

  # Provision MySQL
  config.vm.provision "shell", path: "scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote]

  ####
  # In-Memory Stores
  ##########

  # Provision Redis (without journaling and persistence)
  # config.vm.provision "shell", path: "scripts/redis.sh"

  # Provision Redis (with journaling and persistence)
  # config.vm.provision "shell", path: "scripts/redis.sh", args: "persistent"
  # NOTE: It is safe to run this to add persistence even if originally provisioned without persistence


  ####
  # Local Scripts
  # Any local scripts you may want to run post-provisioning.
  # Add these to the same directory as the Vagrantfile.
  ##########
  # config.vm.provision "shell", path: "./local-script.sh"


end