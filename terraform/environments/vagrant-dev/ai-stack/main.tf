
resource "vagrant_vm" "open-webui-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./openwebui/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./openwebui"
}

resource "vagrant_vm" "searxng-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./searxng/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./searxng"
}



resource "vagrant_vm" "n8n-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./n8n/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./n8n"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../ansible/inventory/vagrant-dev/inventory.tpl", {
    openwebui_port = vagrant_vm.open-webui-container.ports[0][0].host
    openwebui_key  = "${path.cwd}/${vagrant_vm.open-webui-container.vagrantfile_dir}/.vagrant/machines/openwebui/virtualbox/private_key"
    searxng_port   = vagrant_vm.searxng-container.ports[0][0].host
    searxng_key    = "${path.cwd}/${vagrant_vm.searxng-container.vagrantfile_dir}/.vagrant/machines/searxng/virtualbox/private_key"
    n8n_port       = vagrant_vm.n8n-container.ports[0][0].host
    n8n_key        = "${path.cwd}/${vagrant_vm.n8n-container.vagrantfile_dir}/.vagrant/machines/n8n/virtualbox/private_key"
    ollama_host     = var.ollama_host
  })
  filename = "${path.module}/../../../ansible/inventory/vagrant-dev/inventory.ini"
}


