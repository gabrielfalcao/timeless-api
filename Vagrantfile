Vagrant.require_version ">= 1.5.1"

Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true
  config.vm.define "quietness" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.network :forwarded_port, guest: 80, host: 8080
    c.vm.network :forwarded_port, guest: 5000, host: 5000
    c.vm.network :forwarded_port, guest: 9090, host: 9090

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
