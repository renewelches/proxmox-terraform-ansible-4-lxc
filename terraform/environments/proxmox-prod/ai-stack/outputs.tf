
output "ansible_inventory" {
  value = templatefile("${path.module}/../../../../ansible/inventory/proxmox-prod/ai-stack/inventory.tpl", {
    containers = {
      "n8n"        = split("/", proxmox_virtual_environment_container.n8n-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "open-webui" = split("/", proxmox_virtual_environment_container.open-webui-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "searxng"    = split("/", proxmox_virtual_environment_container.searxng-container.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    ollama_host = var.ollama_host
  })
}
