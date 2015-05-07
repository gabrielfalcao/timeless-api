Vagrant.require_version ">= 1.5.1"

Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true
  config.vm.define "quietness" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.network :forwarded_port, guest: 80, host: 8080
    c.vm.network :forwarded_port, guest: 5000, host: 5000
    c.vm.network :forwarded_port, guest: 7000, host: 7000
    c.vm.network :forwarded_port, guest: 7199, host: 7199
    c.vm.network :forwarded_port, guest: 9042, host: 9042
    c.vm.network :forwarded_port, guest: 9160, host: 9160
    c.vm.network :forwarded_port, guest: 61621, host: 61621

    c.vm.provider "virtualbox" do |v|
      # https://github.com/jpetazzo/pipework#virtualbox
      v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
    end

    c.vm.provision :ansible do |ansible|
      ansible.playbook = "playbook.yml"
      # ansible.verbose = 'vvvv'
      ansible.extra_vars = {
            ansible_ssh_user: 'vagrant',
            ansible_connection: 'ssh',
            ansible_ssh_args: '-o ForwardAgent=yes',
        }
    end
  end
end
