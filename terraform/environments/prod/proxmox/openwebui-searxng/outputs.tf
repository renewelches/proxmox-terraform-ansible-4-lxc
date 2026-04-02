
output "ansible_inventory" {
  value = templatefile("${path.module}/../../../../../ansible/inventory/prod/proxmox/openwebui-searxng/inventory.tpl", {
    containers = {
      "open-webui" = split("/", proxmox_virtual_environment_container.open-webui-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "searxng"    = split("/", proxmox_virtual_environment_container.searxng-container.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    ollama_host = var.ollama_host
  })
}
