
resource "vagrant_vm" "prometheus-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./prometheus/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./prometheus"
}

resource "vagrant_vm" "grafana-container" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./grafana/Vagrantfile")),
  }
  get_ports       = true
  vagrantfile_dir = "./grafana"
}


resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../../ansible/inventory/vagrant-dev/observability-stack/inventory.tpl", {
    prometheus_port = vagrant_vm.prometheus-container.ports[0][0].host
    prometheus_key  = "${path.cwd}/${vagrant_vm.prometheus-container.vagrantfile_dir}/.vagrant/machines/prometheus/virtualbox/private_key"
    grafana_port   = vagrant_vm.grafana-container.ports[0][0].host
    grafana_key    = "${path.cwd}/${vagrant_vm.grafana-container.vagrantfile_dir}/.vagrant/machines/grafana/virtualbox/private_key"
    prometheus_ip         = "192.168.56.6"
    ai_stack_ip_openwebui = "192.168.56.3"
    ai_stack_ip_searxng   = "192.168.56.4"
    ai_stack_ip_n8n       = "192.168.56.5"
  })
  filename = "${path.module}/../../../../ansible/inventory/vagrant-dev/observability-stack/inventory.ini"
}


