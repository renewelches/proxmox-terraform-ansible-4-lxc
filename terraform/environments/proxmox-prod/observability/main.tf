provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}


resource "proxmox_virtual_environment_container" "prometheus-container" {
  node_name = var.proxmox_nodes.prometheus

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "prometheus"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ips.prometheus}/24" #fixed IP address
        #address = "dhcp"
        gateway = "192.168.86.1"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.file-system
    size         = 50
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

}

resource "proxmox_virtual_environment_container" "grafana-container" {
  node_name = var.proxmox_nodes.grafana

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "grafana"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ips.grafana}/24"
        #address = "dhcp"
        gateway = "192.168.86.1"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.file-system
    size         = 25
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }
}

# Generate Ansible inventory from container IPs
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../../ansible/inventory/proxmox-prod/observability-stack/inventory.tpl", {
    containers = {
      "prometheus" = split("/", proxmox_virtual_environment_container.prometheus-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "grafana"    = split("/", proxmox_virtual_environment_container.grafana-container.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    ai_stack_ip_openwebui = var.ai_stack_ips.open_webui
    ai_stack_ip_searxng   = var.ai_stack_ips.searxng
    ai_stack_ip_n8n       = var.ai_stack_ips.n8n
  })
  filename = "${path.module}/../../../../ansible/inventory/proxmox-prod/observability-stack/inventory.ini"
}
