resource "vagrant_vm" "forgejo-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./forgejo/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./forgejo"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../../ansible/inventory/vagrant-dev/forgejo-stack/inventory.tpl", {
    forgejo_port = vagrant_vm.forgejo-container.ports[0][0].host
    forgejo_key  = "${path.cwd}/${vagrant_vm.forgejo-container.vagrantfile_dir}/.vagrant/machines/forgejo/virtualbox/private_key"
  })
  filename = "${path.module}/../../../../ansible/inventory/vagrant-dev/forgejo-stack/inventory.ini"
}
