
# More complete output with all details
output "vagrant_vms" {
  value = {
    openwebui = {
      host = "127.0.0.1"
      port = vagrant_vm.open-webui-container.ports[0][0].host
      user = "vagrant"
      key  = "${vagrant_vm.open-webui-container.vagrantfile_dir}/.vagrant/machines/openwebui/virtualbox/private_key"
    }
    searxng = {
      host = "127.0.0.1"
      port = vagrant_vm.searxng-container.ports[0][0].host
      user = "vagrant"
      key  = "${vagrant_vm.searxng-container.vagrantfile_dir}/.vagrant/machines/searxng/virtualbox/private_key"
    }
    n8n = {
      host = "127.0.0.1"
      port = vagrant_vm.n8n-container.ports[0][0].host
      user = "vagrant"
      key  = "${vagrant_vm.n8n-container.vagrantfile_dir}/.vagrant/machines/n8n/virtualbox/private_key"
    }
  }
}
