output "ansible_inventory" {
  value = templatefile("${path.module}/../../../../../ansible/inventory/prod/proxmox/n8n/inventory.tpl", {
    ip = split("/", proxmox_virtual_environment_container.n8n-container.initialization[0].ip_config[0].ipv4[0].address)[0]
  })
}
